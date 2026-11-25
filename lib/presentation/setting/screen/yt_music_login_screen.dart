import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nex_music/core/services/device_info_service.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

class YtMusicLoginScreen extends StatefulWidget {
  const YtMusicLoginScreen({super.key});

  @override
  State<YtMusicLoginScreen> createState() => _YtMusicLoginScreenState();
}

class _YtMusicLoginScreenState extends State<YtMusicLoginScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0.0;
  bool _isProcessing = false;
  String? _currentUserEmail;

  String? _toastMessage;
  Timer? _toastTimer;

  bool _emailCopied = false;
  Timer? _copyTimer;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _copyTimer?.cancel();
    super.dispose();
  }

  bool get _hasEmail =>
      _currentUserEmail != null && _currentUserEmail!.isNotEmpty;

  String _getInitialUrl() {
    if (_hasEmail) {
      return 'https://accounts.google.com/ServiceLogin?service=youtube&continue=https%3A%2F%2Fmusic.youtube.com%2F&login_hint=${Uri.encodeComponent(_currentUserEmail!)}';
    }
    return 'https://accounts.google.com/ServiceLogin?service=youtube&continue=https%3A%2F%2Fmusic.youtube.com%2F';
  }

  Future<void> _copyEmail() async {
    if (!_hasEmail) return;
    await Clipboard.setData(ClipboardData(text: _currentUserEmail!));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _copyTimer?.cancel();
    setState(() => _emailCopied = true);
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _emailCopied = false);
    });
  }

  void _showToast(String message) {
    if (!mounted) return;
    _toastTimer?.cancel();
    setState(() => _toastMessage = message);
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  Future<void> _extractAndSaveCookies(
      {bool showFeedbackOnFailure = false}) async {
    if (_isProcessing || _webViewController == null) return;
    _isProcessing = true;

    try {
      final url = await _webViewController!.getUrl();
      final cookieManager = CookieManager.instance();

      // Only query YouTube domains. NEVER query accounts.google.com or google.com
      // because Google Account cookies have different SAPISID/SID values that
      // would overwrite YouTube's cookies and break InnerTube signature authentication!
      final domains = [
        'https://music.youtube.com',
        'https://music.youtube.com/',
        'https://www.youtube.com',
        'https://www.youtube.com/',
        'https://youtube.com',
        'https://youtube.com/',
      ];

      final cookieMap = <String, String>{};
      for (final domain in domains) {
        try {
          final cookies = await cookieManager.getCookies(url: WebUri(domain));
          for (final c in cookies) {
            if (c.name.isNotEmpty && c.value.isNotEmpty) {
              cookieMap[c.name] = c.value;
            }
          }
        } catch (_) {}
      }

      // Also extract document.cookie from JS context if available
      try {
        final jsCookie = await _webViewController?.evaluateJavascript(
          source: 'document.cookie',
        );
        if (jsCookie != null && jsCookie is String && jsCookie.isNotEmpty) {
          for (final part in jsCookie.split(';')) {
            final trimmed = part.trim();
            final eqIdx = trimmed.indexOf('=');
            if (eqIdx != -1) {
              final k = trimmed.substring(0, eqIdx).trim();
              final v = trimmed.substring(eqIdx + 1).trim();
              if (k.isNotEmpty && !cookieMap.containsKey(k)) {
                cookieMap[k] = v;
              }
            }
          }
        }
      } catch (_) {}

      final hasSapisid = cookieMap.containsKey('__Secure-3PAPISID') ||
          cookieMap.containsKey('SAPISID') ||
          cookieMap.containsKey('__Secure-1PAPISID');
      final hasSid = cookieMap.containsKey('SID') ||
          cookieMap.containsKey('__Secure-3PSID');
      final hasLoginInfo = cookieMap.containsKey('LOGIN_INFO');

      // SAPISID is strictly required to compute SAPISIDHASH for YouTube Music
      final hasAuthCookie = hasSapisid && (hasSid || hasLoginInfo);
      final isAtYtMusic = url != null && url.host.contains('music.youtube.com');

      debugPrint(
          'YTMusic Cookie check: isAtYtMusic=$isAtYtMusic, hasSapisid=$hasSapisid, hasSid=$hasSid, hasLoginInfo=$hasLoginInfo, totalCookies=${cookieMap.length}');

      if (hasAuthCookie && (isAtYtMusic || showFeedbackOnFailure)) {
        final cookieString =
            cookieMap.entries.map((e) => '${e.key}=${e.value}').join('; ');

        await HiveDataBaseSingleton.instance.saveYtMusicCookie(cookieString);

        if (mounted) {
          await context.read<Repository>().updateYtMusicCookies(cookieString);
          showSnackbar(
            context,
            'Connected to YouTube Music successfully!',
          );
          Navigator.of(context).pop(true);
        }
        return;
      }

      if (showFeedbackOnFailure && mounted) {
        if (!isAtYtMusic) {
          _showToast('Please wait until YouTube Music finishes loading.');
        } else {
          _showToast('Signing in… Please wait a few seconds and try again.');
        }
      }
    } catch (e) {
      debugPrint('Error extracting YouTube Music cookies: $e');
      if (showFeedbackOnFailure && mounted) {
        _showToast('Failed to extract cookies. Please try again.');
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAgent = DeviceInfoService.instance.userAgent;
    final background = CupertinoColors.systemGroupedBackground;

    return CupertinoPageScaffold(
      backgroundColor: background,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        // iOS back arrow
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 32,
          onPressed: () => Navigator.of(context).pop(
            HiveDataBaseSingleton.instance.isYtMusicLoggedIn,
          ),
          child: const Icon(CupertinoIcons.back, size: 28),
        ),
        middle: const Text('Connect to YouTube Music'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Refresh
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 32,
              onPressed: () => _webViewController?.reload(),
              child: const Icon(CupertinoIcons.arrow_clockwise, size: 22),
            ),
            // Done button (disabled for now, kept for later use)
            // const SizedBox(width: 8),
            // CupertinoButton(
            //   padding: EdgeInsets.zero,
            //   minSize: 32,
            //   onPressed: () =>
            //       _extractAndSaveCookies(showFeedbackOnFailure: true),
            //   child: const Text(
            //     'Done',
            //     style: TextStyle(fontWeight: FontWeight.w600),
            //   ),
            // ),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (_hasEmail)
                  _AccountHint(
                    email: _currentUserEmail!,
                    copied: _emailCopied,
                    onCopy: _copyEmail,
                  ),
                _ProgressBar(progress: _progress),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(_getInitialUrl()),
                      ),
                      initialSettings: InAppWebViewSettings(
                        isInspectable: kDebugMode,
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        thirdPartyCookiesEnabled: true,
                        sharedCookiesEnabled: true,
                        userAgent: userAgent,
                      ),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      onProgressChanged: (controller, progress) {
                        setState(() {
                          _progress = progress / 100;
                        });
                      },
                      onLoadStop: (controller, url) async {
                        setState(() {
                          _progress = 1.0;
                        });
                        await _extractAndSaveCookies(
                            showFeedbackOnFailure: false);
                      },
                      onUpdateVisitedHistory:
                          (controller, url, isReload) async {
                        if (url != null &&
                            url.host.contains('music.youtube.com')) {
                          await _extractAndSaveCookies(
                              showFeedbackOnFailure: false);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: IgnorePointer(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  offset: _toastMessage == null
                      ? const Offset(0, 0.4)
                      : Offset.zero,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _toastMessage == null ? 0 : 1,
                    child: _Toast(message: _toastMessage ?? ''),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recommendation card shown above the web view.
class _AccountHint extends StatelessWidget {
  final String email;
  final bool copied;
  final VoidCallback onCopy;
  const _AccountHint({
    required this.email,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final fill =
        CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final primary = CupertinoColors.label.resolveFrom(context);
    final tint = CupertinoColors.systemRed.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.person_crop_circle_fill,
                size: 20,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use your Nex Music account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primary,
                      letterSpacing: -0.24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'We recommend signing in with the same account you use in Nex Music.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: tint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(24, 24),
                        onPressed: onCopy,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            copied
                                ? CupertinoIcons.checkmark_alt
                                : CupertinoIcons.doc_on_doc,
                            key: ValueKey(copied),
                            size: 18,
                            color: copied
                                ? CupertinoColors.systemGreen
                                    .resolveFrom(context)
                                : tint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// progress line.
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final track = CupertinoColors.separator.resolveFrom(context);
    final tint = CupertinoColors.systemRed.resolveFrom(context);
    final visible = progress < 1.0;

    return SizedBox(
      height: 2,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1 : 0,
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(color: tint),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  final String message;
  const _Toast({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground
            .resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.info_circle_fill,
            size: 18,
            color: CupertinoColors.systemRed.resolveFrom(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
