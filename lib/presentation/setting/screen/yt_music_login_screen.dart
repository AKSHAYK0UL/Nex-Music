import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  }

  String _getInitialUrl() {
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      return 'https://accounts.google.com/ServiceLogin?service=youtube&continue=https%3A%2F%2Fmusic.youtube.com%2F&login_hint=${Uri.encodeComponent(_currentUserEmail!)}';
    }
    return 'https://accounts.google.com/ServiceLogin?service=youtube&continue=https%3A%2F%2Fmusic.youtube.com%2F';
  }

  Future<void> _extractAndSaveCookies(
      {bool showFeedbackOnFailure = false}) async {
    if (_isProcessing || _webViewController == null) return;
    _isProcessing = true;

    try {
      final url = await _webViewController!.getUrl();
      final cookieManager = CookieManager.instance();

      final domains = [
        'https://music.youtube.com/',
        'https://music.youtube.com',
        'https://www.youtube.com/',
        'https://www.youtube.com',
        'https://youtube.com/',
        'https://youtube.com',
        'https://accounts.google.com/',
        'https://accounts.google.com',
        'https://google.com/',
        'https://google.com',
      ];

      final cookieMap = <String, String>{};
      for (final domain in domains) {
        try {
          final cookies = await cookieManager.getCookies(url: WebUri(domain));
          for (final c in cookies) {
            cookieMap[c.name] = c.value;
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
      final hasLoginInfo = cookieMap.containsKey('LOGIN_INFO');
      final hasSid = cookieMap.containsKey('SID') ||
          cookieMap.containsKey('__Secure-3PSID');

      final hasAuthCookie = hasSapisid || (hasLoginInfo && hasSid);
      final isAtYtMusic = url != null && url.host.contains('music.youtube.com');

      debugPrint(
          'YTMusic Cookie check: isAtYtMusic=$isAtYtMusic, hasSapisid=$hasSapisid, hasLoginInfo=$hasLoginInfo, totalCookies=${cookieMap.length}');

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
        showSnackbar(
          context,
          'Please finish signing in on YouTube Music first.',
        );
      }
    } catch (e) {
      debugPrint('Error extracting YouTube Music cookies: $e');
      if (showFeedbackOnFailure && mounted) {
        showSnackbar(context, 'Failed to extract cookies. Please try again.');
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAgent = (Platform.isAndroid || Platform.isIOS)
        ? "Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36"
        : "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(
            HiveDataBaseSingleton.instance.isYtMusicLoggedIn,
          ),
        ),
        title: const Text(
          'Connect YouTube Music',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh, size: 20),
            onPressed: () => _webViewController?.reload(),
          ),
          TextButton(
            onPressed: () =>
                _extractAndSaveCookies(showFeedbackOnFailure: true),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.red.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.account_circle, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sign in using: $_currentUserEmail',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_progress < 1.0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: theme.dividerColor,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 2.5,
            ),
          Expanded(
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
                await _extractAndSaveCookies(showFeedbackOnFailure: false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
