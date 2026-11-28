import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/collapsing_title_sliver_app_bar.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/presentation/setting/screen/recommendation_info_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen>
    with WidgetsBindingObserver {
  final _hiveDb = HiveDataBaseSingleton.instance;

  late final ValueNotifier<bool> _recommendationNotifier;
  late final ValueNotifier<bool> _cdnNotifier;
  late final ValueNotifier<bool> _batteryUnrestrictedNotifier;
  late final ValueNotifier<String> _cacheSizeNotifier;
  late final ValueNotifier<bool> _isClearingCacheNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recommendationNotifier = ValueNotifier<bool>(_hiveDb.recommendationStatus);
    _cdnNotifier = ValueNotifier<bool>(_hiveDb.cdnEnabled);
    _batteryUnrestrictedNotifier = ValueNotifier<bool>(false);
    _cacheSizeNotifier = ValueNotifier<String>('Calculating...');
    _isClearingCacheNotifier = ValueNotifier<bool>(false);
    if (Platform.isAndroid) {
      _refreshBatteryOptimizationStatus();
    }
    _refreshCacheSize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recommendationNotifier.dispose();
    _cdnNotifier.dispose();
    _batteryUnrestrictedNotifier.dispose();
    _cacheSizeNotifier.dispose();
    _isClearingCacheNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isAndroid) {
      _refreshBatteryOptimizationStatus();
    }
  }

  //  Recommendation

  void _openRecommendationInfo() async {
    final previousStatus = _hiveDb.recommendationStatus;
    final needsRefresh = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RecommendationInfoScreen()),
    );
    final newStatus = _hiveDb.recommendationStatus;
    if (newStatus != previousStatus) {
      _recommendationNotifier.value = newStatus;
    }
    if ((needsRefresh ?? false) && mounted) {
      context.read<HomesectionBloc>().add(RefreshHomeSilentlyEvent());
    }
  }

  //  CDN toggle

  Future<void> _toggleCdn(bool newValue) async {
    await _hiveDb.saveCdnEnabled(newValue);
    _cdnNotifier.value = newValue;
    if (mounted) {
      showSnackbar(
        context,
        newValue ? 'Fast Load enabled' : 'Fast Load disabled',
      );
    }
  }

  //  Background playback

  Future<void> _refreshBatteryOptimizationStatus() async {
    try {
      final isDisabled =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled;
      if (mounted) {
        _batteryUnrestrictedNotifier.value = isDisabled ?? false;
      }
    } catch (e) {
      debugPrint('Error checking battery optimization status: $e');
    }
  }

  Future<void> _toggleBatteryOptimization() async {
    if (!Platform.isAndroid) return;

    final isUnrestricted = _batteryUnrestrictedNotifier.value;
    if (!isUnrestricted) {
      try {
        final opened = await DisableBatteryOptimization
            .showDisableBatteryOptimizationSettings();
        if (opened == false && mounted) {
          await openAppSettings();
        }
      } catch (e) {
        debugPrint('Error disabling battery optimization: $e');
        if (mounted) {
          await openAppSettings();
        }
      }
      await _refreshBatteryOptimizationStatus();
      return;
    }

    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Background Playback'),
        content: const Text(
          'Battery optimization is already disabled for Nex Music. '
          'You can review or change this in System Settings.',
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  //  Storage & Cache

  Future<List<Directory>> _getSafeCacheDirectories() async {
    final protectedPaths = <String>[];
    try {
      protectedPaths.add((await getApplicationDocumentsDirectory()).path);
    } catch (_) {}
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        protectedPaths.add(externalDir.path);
      }
    } catch (_) {}

    bool isProtected(String path) {
      for (final protected in protectedPaths) {
        if (path == protected ||
            path.startsWith('$protected${Platform.pathSeparator}')) {
          return true;
        }
      }
      return false;
    }

    final seenPaths = <String>{};
    final cacheDirs = <Directory>[];

    Future<void> tryAdd(Future<Directory> Function() getter) async {
      try {
        final dir = await getter();
        if (seenPaths.add(dir.path) &&
            !isProtected(dir.path) &&
            await dir.exists()) {
          cacheDirs.add(dir);
        }
      } catch (_) {}
    }

    await tryAdd(getTemporaryDirectory);
    await tryAdd(getApplicationCacheDirectory);
    return cacheDirs;
  }

  Future<int> _calculateDirectorySize(Directory dir) async {
    int totalBytes = 0;
    try {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            totalBytes += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return totalBytes;
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> _refreshCacheSize() async {
    try {
      final dirs = await _getSafeCacheDirectories();
      int totalBytes = 0;
      for (final dir in dirs) {
        totalBytes += await _calculateDirectorySize(dir);
      }
      if (mounted) {
        _cacheSizeNotifier.value = _formatBytes(totalBytes);
      }
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      if (mounted) {
        _cacheSizeNotifier.value = 'Tap to clean';
      }
    }
  }

  void _confirmClearCache() {
    if (_isClearingCacheNotifier.value) return;

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will clear cached thumbnails, metadata, and temporary audio data. '
          'Your downloaded songs, playlists, and listening history will not be deleted.',
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              _clearAppCache();
            },
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAppCache() async {
    _isClearingCacheNotifier.value = true;
    try {
      await DefaultCacheManager().emptyCache();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      final dirs = await _getSafeCacheDirectories();
      for (final dir in dirs) {
        try {
          await for (final entity in dir.list(followLinks: false)) {
            final lowerPath = entity.path.toLowerCase();
            if (lowerPath.endsWith('.db') ||
                lowerPath.endsWith('.db-journal') ||
                lowerPath.endsWith('.db-wal') ||
                lowerPath.endsWith('.db-shm')) {
              continue;
            }
            try {
              await entity.delete(recursive: true);
            } catch (_) {}
          }
        } catch (_) {}
      }

      await _refreshCacheSize();
      if (mounted) {
        showSnackbar(context, 'Cache cleared');
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      if (mounted) {
        showSnackbar(context, 'Failed to clear cache');
      }
    } finally {
      if (mounted) {
        _isClearingCacheNotifier.value = false;
      }
    }
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // appBar: AppBar(
      //   backgroundColor: theme.scaffoldBackgroundColor,
      //   elevation: 0,
      //   leadingWidth: 100,
      //   leading: GestureDetector(
      //     onTap: () => Navigator.of(context).pop(),
      //     child: Row(
      //       children: [
      //         const SizedBox(width: 8),
      //         const Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
      //         Text(
      //           'Settings',
      //           style: TextStyle(
      //             color: Colors.red,
      //             fontSize: 17,
      //             backgroundColor: theme.scaffoldBackgroundColor,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            CollapsingTitleSliverAppBar(
              title: "Advanced",
              backLabel: "Settings",
              onBackTap: () => Navigator.pop(context),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
                  //   child: Text(
                  //     'Advanced',
                  //     style: TextStyle(
                  //       fontFamily: 'serif',
                  //       fontSize: 30,
                  //       fontWeight: FontWeight.bold,
                  //       color: theme.colorScheme.onSurface,
                  //       letterSpacing: -0.5,
                  //     ),
                  //   ),
                  // ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PERSONALISATION
                      _buildSectionHeader('PERSONALISATION', textSecondary),
                      _buildGroupedContainer(cardColor, [
                        ValueListenableBuilder<bool>(
                          valueListenable: _recommendationNotifier,
                          builder: (context, value, _) {
                            final isLoggedIn = _hiveDb.isYtMusicLoggedIn;
                            final subtitle = isLoggedIn
                                ? (value
                                    ? 'Enabled · Tap to manage'
                                    : 'Paused · Tap to manage')
                                : 'Tap to learn more & connect';
                            return _buildSwitchTile(
                              title: 'Recommendations',
                              subtitle: subtitle,
                              icon: CupertinoIcons.sparkles,
                              iconColor: Colors.orange,
                              value: value,
                              onTap: _openRecommendationInfo,
                              onChanged: (_) => _openRecommendationInfo(),
                              theme: theme,
                            );
                          },
                        ),
                      ]),
                      _buildSectionHeader('PERFORMANCE', textSecondary),
                      _buildGroupedContainer(cardColor, [
                        ValueListenableBuilder<bool>(
                          valueListenable: _cdnNotifier,
                          builder: (context, value, _) {
                            return _buildSwitchTile(
                              title: 'Fast Load (CDN Cache)',
                              subtitle: 'Stream music without delays',
                              icon: CupertinoIcons.bolt_fill,
                              iconColor: const Color(0xFF34C759),
                              value: value,
                              onChanged: _toggleCdn,
                              theme: theme,
                            );
                          },
                        ),
                      ]),
                      _buildFootnote(
                        'CDN caching stores frequently accessed data nearby so '
                        'it loads faster. Disable this if you notice stale '
                        'artwork or playlist covers.',
                        textSecondary,
                      ),
                      if (Platform.isAndroid) ...[
                        _buildSectionHeader(
                            'BACKGROUND PLAYBACK', textSecondary),
                        _buildGroupedContainer(cardColor, [
                          ValueListenableBuilder<bool>(
                            valueListenable: _batteryUnrestrictedNotifier,
                            builder: (context, value, _) {
                              final subtitle = value
                                  ? 'Battery optimization is disabled'
                                  : 'Battery optimization is enabled';
                              return _buildSwitchTile(
                                title: 'Disable Optimization',
                                subtitle: subtitle,
                                icon: CupertinoIcons.battery_100,
                                iconColor: const Color(0xFF007AFF),
                                value: value,
                                onTap: _toggleBatteryOptimization,
                                onChanged: (_) => _toggleBatteryOptimization(),
                                theme: theme,
                              );
                            },
                          ),
                        ]),
                        _buildFootnote(
                          'Disabling battery optimization prevents Android from '
                          'stopping Nex Music playback when the app is in the '
                          'background or the screen is off.',
                          textSecondary,
                        ),
                      ],
                      _buildSectionHeader('STORAGE', textSecondary),
                      _buildGroupedContainer(cardColor, [
                        ValueListenableBuilder<bool>(
                          valueListenable: _isClearingCacheNotifier,
                          builder: (context, isClearing, _) {
                            return ValueListenableBuilder<String>(
                              valueListenable: _cacheSizeNotifier,
                              builder: (context, cacheSize, _) {
                                return _buildActionTile(
                                  title: 'Clear Cache',
                                  subtitle: isClearing
                                      ? 'Clearing cache...'
                                      : 'Cache used: $cacheSize',
                                  icon: CupertinoIcons.trash,
                                  iconColor: CupertinoColors.systemRed,
                                  onTap: isClearing ? null : _confirmClearCache,
                                  trailing: isClearing
                                      ? const CupertinoActivityIndicator(
                                          radius: 10,
                                        )
                                      : Icon(
                                          CupertinoIcons.chevron_forward,
                                          color: theme.dividerColor,
                                          size: 18,
                                        ),
                                  theme: theme,
                                );
                              },
                            );
                          },
                        ),
                      ]),
                      _buildFootnote(
                        'Clearing cache removes temporary thumbnails, metadata, '
                        'and cached audio data to free up space. It will not '
                        'delete any of your downloaded songs or listening history.',
                        textSecondary,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  // ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Widgets

  Widget _buildSectionHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 20),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildGroupedContainer(Color cardColor, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return _buildActionTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: CupertinoColors.destructiveRed,
        onChanged: onChanged,
      ),
      theme: theme,
    );
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
    Widget? trailing,
    required ThemeData theme,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.transparent,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          : null,
      trailing: trailing,
    );
  }

  Widget _buildFootnote(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: color, height: 1.4),
      ),
    );
  }
}
