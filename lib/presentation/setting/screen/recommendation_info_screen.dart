import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/collapsing_title_sliver_app_bar.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/yt_music_connection_status.dart';
import 'package:nex_music/presentation/setting/screen/recommendation_info_shimmer_screen.dart';
import 'package:nex_music/presentation/setting/screen/yt_music_login_screen.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

// enum _phase { idle, connecting, reconnecting, pausing, removing }

// The seven UI states described in the update plan.
// enum _Status {
//   notConnected,
//   connecting,
//   connected,
//   paused,
//   reconnecting,
//   error,
//   working,
// }

class RecommendationInfoScreen extends StatefulWidget {
  const RecommendationInfoScreen({super.key});

  @override
  State<RecommendationInfoScreen> createState() =>
      _RecommendationInfoScreenState();
}

class _RecommendationInfoScreenState extends State<RecommendationInfoScreen> {
  static const Color _accent = CupertinoColors.destructiveRed;

  static const bool _storageIsEncrypted = true;

  static const List<String> _integrationSites = [
    'https://music.youtube.com',
    'https://www.youtube.com',
    'https://accounts.youtube.com',
    'https://accounts.google.com',
    'https://www.google.com',
  ];

  final _hiveDb = HiveDataBaseSingleton.instance;

  bool _hasAgreed = false;
  late bool _isLoggedIn;
  late bool _recommendationOn;

  YtMusicConnectPhase _phase = YtMusicConnectPhase.idle;
  String? _errorMessage;
  VoidCallback? _retryAction;

  // Set to true whenever an action changes recommendation state so that
  // phone_setting.dart can dispatch GetHomeSectonDataEvent on pop keeping
  // the event out of this screen and preventing the HomesectionBloc
  // LoadingState from triggering the full-screen splash.
  bool _needsHomeRefresh = false;

  bool get _isBusy => _phase != YtMusicConnectPhase.idle;

  YtMusicConnectionStatus get _status {
    switch (_phase) {
      case YtMusicConnectPhase.connecting:
        return YtMusicConnectionStatus.connecting;
      case YtMusicConnectPhase.reconnecting:
        return YtMusicConnectionStatus.reconnecting;
      case YtMusicConnectPhase.pausing:
      case YtMusicConnectPhase.removing:
        return YtMusicConnectionStatus.working;
      case YtMusicConnectPhase.idle:
        if (_errorMessage != null) return YtMusicConnectionStatus.error;
        if (_isLoggedIn) {
          return _recommendationOn
              ? YtMusicConnectionStatus.connected
              : YtMusicConnectionStatus.paused;
        }
        return YtMusicConnectionStatus.notConnected;
    }
  }

  @override
  void initState() {
    super.initState();
    _syncFromStorage();
  }

  // The UI only ever shows "Connected" when storage says it is.
  void _syncFromStorage() {
    _isLoggedIn = _hiveDb.isYtMusicLoggedIn;
    _recommendationOn = _isLoggedIn && _hiveDb.recommendationStatus;
  }

  Future<void> _authenticate({
    required bool isReconnect,
    required String successMessage,
  }) async {
    if (_isBusy) return;

    final navigator = Navigator.of(context);

    setState(() {
      _phase = isReconnect
          ? YtMusicConnectPhase.reconnecting
          : YtMusicConnectPhase.connecting;
      _errorMessage = null;
      _retryAction = null;
    });

    String? error;
    try {
      final result = await navigator.push<bool>(
        MaterialPageRoute(builder: (_) => const YtMusicLoginScreen()),
      );
      if (!mounted) return;

      if (result == null) {
        // Cancelled by the person return quietly to the previous state.
        setState(() => _phase = YtMusicConnectPhase.idle);
        return;
      }

      if (result == true) {
        await _hiveDb.saveRecommendation(true);
        if (!mounted) return;
        if (!_hiveDb.isYtMusicLoggedIn) {
          // Never show "Connected" unless a session was actually stored.
          await _hiveDb.saveRecommendation(false);
          error = 'You signed in, but the session couldn\u2019t be saved. '
              'Please try again.';
        }
      } else {
        error = 'Sign-in wasn\u2019t completed. Check your internet '
            'connection and try again.';
      }
    } catch (e) {
      debugPrint('YT Music authentication error: $e');
      error = 'Something went wrong while connecting. Please try again.';
    }

    if (!mounted) return;

    if (error == null) {
      setState(() {
        _syncFromStorage();
        _phase = YtMusicConnectPhase.idle;
      });
      HapticFeedback.lightImpact();
      _needsHomeRefresh = true;
      showSnackbar(context, successMessage);
    } else {
      setState(() {
        _syncFromStorage();
        _phase = YtMusicConnectPhase.idle;
        _errorMessage = error;
        _retryAction = () => _authenticate(
              isReconnect: isReconnect,
              successMessage: successMessage,
            );
      });
    }
  }

  void _connectYtMusic() => _authenticate(
        isReconnect: false,
        successMessage: 'Connected to YouTube Music!',
      );

  void _reconnect() => _authenticate(
        isReconnect: true,
        successMessage: 'Reconnected to YouTube Music!',
      );

  // Resuming reuses the same flow. The webview normally still holds the
  // session, so this finishes almost instantly without asking for a password.
  void _resume() => _authenticate(
        isReconnect: true,
        successMessage: 'Recommendations resumed',
      );

  // Pauses recommendations: turns the feature off and clears the in-memory
  // cookies, but keeps the stored session so the person can resume later.
  Future<void> _disconnectPause() async {
    if (_isBusy) return;

    final repo = context.read<Repository>();

    setState(() {
      _phase = YtMusicConnectPhase.pausing;
      _errorMessage = null;
    });

    try {
      await _hiveDb.saveRecommendation(false);
      await repo.updateYtMusicCookies(null);
      if (!mounted) return;
      setState(() {
        _recommendationOn = false;
        _phase = YtMusicConnectPhase.idle;
      });
      _needsHomeRefresh = true;
      showSnackbar(context, 'Recommendations paused');
    } catch (e) {
      debugPrint('Error pausing recommendations: $e');
      if (!mounted) return;
      setState(() {
        _syncFromStorage();
        _phase = YtMusicConnectPhase.idle;
        _errorMessage =
            'Couldn\u2019t pause Recommendations. Please try again.';
        _retryAction = _disconnectPause;
      });
    }
  }

  // Permanently removes every piece of YouTube Music integration data:

  Future<void> _removeAccount() async {
    if (_isBusy) return;

    final repo = context.read<Repository>();

    setState(() {
      _phase = YtMusicConnectPhase.removing;
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();

    // Stop using the session immediately, then delete it.
    try {
      await repo.updateYtMusicCookies(null);
      await _hiveDb.clearYtMusicCookie();
      await _hiveDb.saveRecommendation(false);
    } catch (e) {
      debugPrint('Error clearing stored YT Music session: $e');
      if (!mounted) return;
      setState(() {
        _syncFromStorage();
        _phase = YtMusicConnectPhase.idle;
        _errorMessage = 'Couldn\u2019t remove your account. Please try again.';
        _retryAction = _removeAccount;
      });
      return;
    }

    // Clear WebView data that belongs to this integration only.
    final webViewCleared = await _clearIntegrationWebViewData();

    if (!mounted) return;
    setState(() {
      _syncFromStorage();
      _hasAgreed = false;
      _phase = YtMusicConnectPhase.idle;
    });
    _needsHomeRefresh = true;
    showSnackbar(
      context,
      webViewCleared
          ? 'Account removed. Sign in again to use recommendations.'
          : 'Account removed, but some web data couldn\u2019t be cleared. '
              'Restart the app to finish.',
    );
  }

  // Deletes cookies for the YouTube / Google sites used by the login flow,

  Future<bool> _clearIntegrationWebViewData() async {
    var allCleared = true;

    // Cookies (scoped to the integration's sites).
    final cookieManager = CookieManager.instance();
    for (final site in _integrationSites) {
      try {
        final url = WebUri(site);
        final cookies = await cookieManager.getCookies(url: url);
        for (final cookie in cookies) {
          await cookieManager.deleteCookie(
            url: url,
            name: cookie.name,
            domain: cookie.domain,
            path: cookie.path ?? '/',
          );
        }
      } catch (e) {
        allCleared = false;
        debugPrint('Error clearing cookies for $site: $e');
      }
    }

    // Cache.
    try {
      await InAppWebViewController.clearAllCache();
    } catch (e) {
      allCleared = false;
      debugPrint('Error clearing webview cache: $e');
    }

    try {
      final storage = WebStorageManager.instance();
      final origins = await storage.getOrigins();
      for (final o in origins) {
        final origin = o.origin ?? '';
        if (_isIntegrationHost(origin)) {
          await storage.deleteOrigin(origin: origin);
        }
      }
    } catch (e) {
      allCleared = false;
      debugPrint('Error clearing webview storage: $e');
    }

    return allCleared;
  }

  bool _isIntegrationHost(String value) {
    final v = value.toLowerCase();
    return v.contains('youtube.com') ||
        v.contains('google.com') ||
        v.contains('googleusercontent.com') ||
        v.contains('gstatic.com');
  }

  // Manage sheet + remove confirmation
  void _showManageSheet() {
    if (_isBusy) return;
    final isPaused = _status == YtMusicConnectionStatus.paused;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: CupertinoActionSheet(
          title: const Text('Manage Your YouTube Music Account'),
          message: Text(
            isPaused
                ? 'Recommendations are paused. Your connection is saved, so '
                    'you can resume at any time.'
                : 'Your account is connected and personalizing your home feed.',
          ),
          actions: [
            if (!isPaused)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  _reconnect();
                },
                child: const Text('Reconnect'),
              ),
            if (isPaused)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  _resume();
                },
                child: const Text('Resume Recommendations'),
              )
            else
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(ctx);
                  _disconnectPause();
                },
                child: const Text('Disconnect / Pause'),
              ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(ctx);
                _confirmRemoveAccount();
              },
              child: const Text('Remove Account'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ),
      ),
    );
  }

  void _confirmRemoveAccount() {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Remove Account?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'This permanently deletes your YouTube Music session and its '
            'web data from this device. It can\u2019t be undone \u2014 you\u2019ll '
            'need to sign in again to use Recommendations.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _removeAccount();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final cardColor = theme.cardColor;

    // Show the shimmer as a full overlay during pause / remove so the
    // underlying HomesectionBloc never gets a chance to show its splash.
    final bool showShimmerOverlay = _phase == YtMusicConnectPhase.pausing ||
        _phase == YtMusicConnectPhase.removing;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                CollapsingTitleSliverAppBar(
                  title: 'Recommendations',
                  backLabel: 'Advanced',
                  onBackTap: () => Navigator.of(context).pop(_needsHomeRefresh),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildHero(theme, textSecondary),

                        //  STATUS (connecting / connected / paused / error)
                        if (_status != YtMusicConnectionStatus.notConnected)
                          _buildStatusCard(theme, cardColor, textSecondary),

                        // ABOUT
                        _buildSectionHeader('ABOUT', textSecondary),
                        _buildGroupedContainer(cardColor, [
                          _buildInfoCard(
                            icon: CupertinoIcons.sparkles,
                            iconColor: Colors.orange,
                            title: 'What is Recommendations?',
                            body:
                                'Recommendations personalizes your home feed with '
                                'songs, mixes, and playlists based on your YouTube '
                                'Music listening history. It\u2019s optional, and '
                                'you can turn it off at any time.',
                            theme: theme,
                          ),
                          _divider(theme),
                          _buildInfoCard(
                            icon: CupertinoIcons.arrow_2_circlepath,
                            iconColor: Colors.blue,
                            title: 'How does it work?',
                            body:
                                'Once you connect, Nex Music uses your YouTube '
                                'Music session to load suggestions made for you. '
                                'Music you play in Nex Music is reported back to '
                                'YouTube Music, which helps improve future '
                                'suggestions.',
                            theme: theme,
                          ),
                        ]),

                        //  PERMISSIONS & ACCESS
                        _buildSectionHeader(
                            'PERMISSIONS & ACCESS', textSecondary),
                        _buildGroupedContainer(cardColor, [
                          _buildInfoCard(
                            icon: CupertinoIcons.person_crop_circle_fill,
                            iconColor: const Color(0xFF007AFF),
                            title: 'What access is needed',
                            body:
                                'You sign in to your Google account on Google\u2019s '
                                'own page inside the app. Nex Music never sees or '
                                'stores your password. After sign-in, the app keeps '
                                'the session cookies that YouTube Music provides.',
                            theme: theme,
                          ),
                          _divider(theme),
                          _buildInfoCard(
                            icon: CupertinoIcons.music_note_list,
                            iconColor: const Color(0xFFFF2D55),
                            title: 'How it\u2019s used',
                            body:
                                'This access is used only for Recommendations: '
                                'to request your personalized suggestions and to '
                                'report what you play. It isn\u2019t intended to '
                                'reach any unrelated YouTube or Google account '
                                'information.',
                            theme: theme,
                          ),
                        ]),

                        //  PRIVACY & SECURITY
                        _buildSectionHeader(
                            'PRIVACY & SECURITY', textSecondary),
                        _buildGroupedContainer(cardColor, [
                          _buildInfoCard(
                            icon: CupertinoIcons.lock_shield_fill,
                            iconColor: const Color(0xFF34C759),
                            title: 'Stored on your device only',
                            body: _storageIsEncrypted
                                ? 'Your session data stays in the app\u2019s private '
                                    'storage and is encrypted at rest using your '
                                    'device\u2019s secure storage. It\u2019s never kept '
                                    'in plain text, never uploaded to a server, and '
                                    'never shared with third parties. It\u2019s also '
                                    'kept separate from unrelated app features.'
                                : 'Your session data stays in the app\u2019s private '
                                    'storage on this device. It\u2019s never uploaded '
                                    'to a server or shared with third parties, and '
                                    'it\u2019s kept separate from unrelated app '
                                    'features.',
                            theme: theme,
                          ),
                          // _divider(theme),
                          // _buildInfoCard(
                          //   icon: CupertinoIcons.exclamationmark_shield_fill,
                          //   iconColor: const Color(0xFFFF9500),
                          //   title: 'Google security notification',
                          //   body:
                          //       'Google may email you a security alert saying your '
                          //       'account was accessed from your '
                          //       '${DeviceInfoService.instance.deviceName}. '
                          //       "That\u2019s because the sign-in page in Nex Music "
                          //       'identifies as your device for compatibility with '
                          //       'YouTube Music. Whether Google sends an alert is '
                          //       'up to Google and can\u2019t be guaranteed. If the '
                          //       'timing matches when you signed in, it\u2019s '
                          //       'expected.',
                          //   theme: theme,
                          // ),
                        ]),

                        //  YOUR CONTROLS
                        _buildSectionHeader('YOUR CONTROLS', textSecondary),
                        _buildGroupedContainer(cardColor, [
                          _buildInfoCard(
                            icon: CupertinoIcons.arrow_clockwise,
                            iconColor: const Color(0xFF5856D6),
                            title: 'Reconnect',
                            body:
                                'Refresh your connection if it expires or stops '
                                'working.',
                            theme: theme,
                          ),
                          _divider(theme),
                          _buildInfoCard(
                            icon: CupertinoIcons.pause_fill,
                            iconColor: const Color(0xFFFF9500),
                            title: 'Disconnect / Pause',
                            body:
                                'Stop using your account for Recommendations. Your '
                                'connection is kept so you can resume without '
                                'signing in again.',
                            theme: theme,
                          ),
                          _divider(theme),
                          _buildInfoCard(
                            icon: CupertinoIcons.trash_fill,
                            iconColor: CupertinoColors.destructiveRed,
                            title: 'Remove Account',
                            body:
                                'Permanently delete all YouTube Music session data '
                                'from this device. You\u2019ll need to sign in again '
                                'to use Recommendations.',
                            theme: theme,
                          ),
                        ]),

                        // Consent (only when establishing a new connection)
                        if (!_isLoggedIn) ...[
                          const SizedBox(height: 28),
                          _buildGroupedContainer(cardColor, [
                            _buildAgreementRow(theme),
                          ]),
                        ],

                        const SizedBox(height: 20),
                        _buildActionButton(theme),
                        if (!_isLoggedIn && !_hasAgreed && !_isBusy)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 10, 32, 0),
                            child: Text(
                              'Select the checkbox above to continue.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 13, color: textSecondary),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Shimmer overlay for pause / remove operations — covers the entire
        // screen so the underlying HomesectionBloc LoadingState never shows.
        if (showShimmerOverlay)
          RecommendationInfoShimmerScreen(
            showStatusCard: true,
            showConsentRow: !_isLoggedIn,
            // Back button is blocked while the operation runs.
            showBackButton: false,
          ),
      ],
    );
  }

  // Hero

  Widget _buildHero(ThemeData theme, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.sparkles,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recommendations',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Personalize your home feed with YouTube Music',
              style: TextStyle(fontSize: 15, color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Status card

  Widget _buildStatusCard(
    ThemeData theme,
    Color cardColor,
    Color textSecondary,
  ) {
    final status = _status;

    late final Widget leading;
    late final String title;
    late final String subtitle;
    Color titleColor = theme.colorScheme.onSurface;

    switch (status) {
      case YtMusicConnectionStatus.connecting:
        leading = const CupertinoActivityIndicator();
        title = 'Connecting\u2026';
        subtitle = 'Finish signing in to YouTube Music.';
        break;
      case YtMusicConnectionStatus.reconnecting:
        leading = const CupertinoActivityIndicator();
        title = 'Reconnecting\u2026';
        subtitle = 'Restoring your YouTube Music connection.';
        break;
      case YtMusicConnectionStatus.working:
        leading = const CupertinoActivityIndicator();
        title = _phase == YtMusicConnectPhase.removing
            ? 'Removing account\u2026'
            : 'Pausing\u2026';
        subtitle = 'This only takes a moment.';
        break;
      case YtMusicConnectionStatus.connected:
        leading = const Icon(
          CupertinoIcons.checkmark_circle_fill,
          color: Color(0xFF34C759),
          size: 26,
        );
        title = 'Connected';
        subtitle = 'Your home feed is personalized with YouTube Music.';
        break;
      case YtMusicConnectionStatus.paused:
        leading = const Icon(
          CupertinoIcons.pause_circle_fill,
          color: Color(0xFFFF9500),
          size: 26,
        );
        title = 'Paused';
        subtitle = 'Recommendations are off. Your connection is saved.';
        break;
      case YtMusicConnectionStatus.error:
        leading = const Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          color: CupertinoColors.destructiveRed,
          size: 26,
        );
        title = 'Something went wrong';
        subtitle = _errorMessage ?? 'Please try again.';
        titleColor = theme.colorScheme.onSurface;
        break;
      case YtMusicConnectionStatus.notConnected:
        return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 26, height: 26, child: Center(child: leading)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (status == YtMusicConnectionStatus.error &&
                _retryAction != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(44, 44),
                  onPressed: _isBusy ? null : _retryAction,
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Info card

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Consent row + checkbox

  static const String _consentText =
      'I have read and understood the information above, and I agree to '
      'connect my YouTube Music account.';

  void _toggleConsent() {
    if (_isBusy) return;
    HapticFeedback.selectionClick();
    setState(() => _hasAgreed = !_hasAgreed);
  }

  Widget _buildAgreementRow(ThemeData theme) {
    return Semantics(
      container: true,
      checked: _hasAgreed,
      enabled: !_isBusy,
      label: _consentText,
      onTap: _toggleConsent,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: _toggleConsent,
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckbox(theme),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _consentText,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: _hasAgreed ? _accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _hasAgreed ? _accent : theme.dividerColor,
          width: 1.5,
        ),
      ),
      child: _hasAgreed
          ? const Icon(CupertinoIcons.check_mark, color: Colors.white, size: 16)
          : null,
    );
  }

  // Action button
  Widget _buildActionButton(ThemeData theme) {
    final bool buttonEnabled = !_isBusy && (_isLoggedIn || _hasAgreed);

    final bool showSpinner = _phase == YtMusicConnectPhase.connecting ||
        _phase == YtMusicConnectPhase.reconnecting;
    final String buttonText = _isLoggedIn ? 'Manage' : 'Connect YouTube Music';

    final Color fg = buttonEnabled || showSpinner
        ? Colors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.35);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonEnabled || showSpinner
                ? _accent.withValues(alpha: buttonEnabled ? 1 : 0.7)
                : theme.colorScheme.onSurface.withValues(alpha: 0.08),
            foregroundColor: fg,
            disabledBackgroundColor: showSpinner
                ? _accent.withValues(alpha: 0.7)
                : theme.colorScheme.onSurface.withValues(alpha: 0.08),
            disabledForegroundColor: fg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: buttonEnabled
              ? () => _isLoggedIn ? _showManageSheet() : _connectYtMusic()
              : null,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: showSpinner
                ? const CupertinoActivityIndicator(
                    key: ValueKey('spinner'),
                    color: Colors.white,
                  )
                : Text(
                    buttonText,
                    key: ValueKey(buttonText),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Shared builders

  Widget _buildSectionHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 20),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
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

  Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 60,
      color: theme.dividerColor,
    );
  }
}
