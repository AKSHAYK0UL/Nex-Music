import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/presentation/setting/screen/recommendation_info_screen.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recommendationNotifier = ValueNotifier<bool>(_hiveDb.recommendationStatus);
    _cdnNotifier = ValueNotifier<bool>(_hiveDb.cdnEnabled);
    _batteryUnrestrictedNotifier = ValueNotifier<bool>(false);
    if (Platform.isAndroid) {
      _refreshBatteryOptimizationStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recommendationNotifier.dispose();
    _cdnNotifier.dispose();
    _batteryUnrestrictedNotifier.dispose();
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

  // Build

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 17,
                  backgroundColor: theme.scaffoldBackgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
              child: Text(
                'Advanced',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
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
                      _buildSectionHeader('BACKGROUND PLAYBACK', textSecondary),
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
                        'stopping music playback when the app is in the '
                        'background or the screen is off.',
                        textSecondary,
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
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
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: CupertinoColors.destructiveRed,
        onChanged: onChanged,
      ),
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
