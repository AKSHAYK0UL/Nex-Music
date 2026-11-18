import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

// Provides  device information (OS, model, etc.) and builds a
// browser like user agent string for use in webviews.

// Call [ensureInitialized] once at app startup (in `main`) before
// accessing [userAgent] or [deviceName].
class DeviceInfoService {
  DeviceInfoService._internal();
  static final DeviceInfoService instance = DeviceInfoService._internal();

  BaseDeviceInfo? _deviceInfo;
  String? _userAgent;
  String? _deviceName;

  // Fetches device info if not already loaded.
  Future<void> ensureInitialized() async {
    if (_deviceInfo != null) return;
    try {
      _deviceInfo = await DeviceInfoPlugin().deviceInfo;
      _buildFromInfo(_deviceInfo!);
    } catch (e) {
      debugPrint('DeviceInfoService: failed to load device info: $e');
      _buildFallback();
    }
  }

  // Platform specific builders

  void _buildFromInfo(BaseDeviceInfo info) {
    if (info is AndroidDeviceInfo) {
      _deviceName = info.model; // e.g. "Pixel 7"
      _userAgent =
          'Mozilla/5.0 (Linux; Android ${info.version.release}; ${info.model}) '
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 '
          'Mobile Safari/537.36';
    } else if (info is IosDeviceInfo) {
      //   the identifier Google would reference.
      _deviceName = info.utsname.machine;
      _userAgent = 'Mozilla/5.0 (iPhone; CPU iPhone OS '
          "${info.systemVersion.replaceAll('.', '_')} like Mac OS X) "
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 '
          'Mobile Safari/537.36';
    } else if (info is WindowsDeviceInfo) {
      _deviceName = 'Windows PC';
      _userAgent =
          'Mozilla/5.0 (Windows NT ${info.majorVersion}.${info.minorVersion}; '
          'Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/126.0.0.0 Safari/537.36';
    } else if (info is MacOsDeviceInfo) {
      _deviceName = 'Mac';
      _userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X '
          '${info.majorVersion}_${info.minorVersion}_${info.patchVersion}) '
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 '
          'Safari/537.36';
    } else if (info is LinuxDeviceInfo) {
      _deviceName = 'Linux';
      _userAgent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';
    } else {
      _buildFallback();
    }
  }

  // Generic fallback when device info can't be resolved.
  void _buildFallback() {
    _deviceName = 'this device';
    if (kIsWeb) {
      _userAgent =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';
    } else if (Platform.isAndroid || Platform.isIOS) {
      _userAgent = 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36';
    } else {
      _userAgent =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';
    }
  }

  // Public getters
  // Browser-like user agent string for the current device.
  // Falls back to a generic desktop string if hasn't completed yet.
  String get userAgent =>
      _userAgent ??
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';

  String get deviceName => _deviceName ?? 'this device';
}
