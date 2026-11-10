import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Handles local notifications for download progress, completion and error.
// Each song gets a unique notification ID derived from its vId hashcode so
// multiple downloads show as separate, updatable notifications.
class DownloadNotificationService {
  static final DownloadNotificationService _instance =
      DownloadNotificationService._internal();
  factory DownloadNotificationService() => _instance;
  DownloadNotificationService._internal();

  static const String _channelId = 'nex_music_downloads';
  static const String _channelName = 'Downloads';
  static const String _channelDesc = 'Shows music download progress';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (!Platform.isAndroid) {
      _initialized = true;
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Request POST_NOTIFICATIONS permission on Android 13+.
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  // Returns a stable notification ID for a song vId.
  int _notifId(String vId) => vId.hashCode.abs() % 100000;

  // Shows or updates a progress notification for songName
  Future<void> showProgress({
    required String vId,
    required String songName,
    required int progress,
  }) async {
    if (!_initialized || !Platform.isAndroid) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      channelShowBadge: false,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      indeterminate: false,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/launcher_icon',
    );

    await _plugin.show(
      _notifId(vId),
      'Downloading – $songName',
      '$progress%',
      NotificationDetails(android: androidDetails),
    );
  }

  // Shows a "paused" notification for songName
  Future<void> showPaused({
    required String vId,
    required String songName,
    required int progress,
  }) async {
    if (!_initialized || !Platform.isAndroid) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      channelShowBadge: false,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      indeterminate: false,
      ongoing: false,
      autoCancel: false,
      icon: '@mipmap/launcher_icon',
    );

    await _plugin.show(
      _notifId(vId),
      'Paused – $songName',
      '$progress% • Tap to resume in the app',
      NotificationDetails(android: androidDetails),
    );
  }

  // Shows a completion notification for songName
  Future<void> showCompleted({
    required String vId,
    required String songName,
  }) async {
    if (!_initialized || !Platform.isAndroid) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      channelShowBadge: true,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      autoCancel: true,
      icon: '@mipmap/launcher_icon',
    );

    await _plugin.show(
      _notifId(vId),
      'Download complete',
      songName,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Shows an error notification for songName
  Future<void> showError({
    required String vId,
    required String songName,
    required String error,
  }) async {
    if (!_initialized || !Platform.isAndroid) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      channelShowBadge: false,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      autoCancel: true,
      icon: '@mipmap/launcher_icon',
    );

    await _plugin.show(
      _notifId(vId),
      'Download failed – $songName',
      error,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Cancels the notification for a specific song.
  Future<void> cancel(String vId) async {
    if (!_initialized || !Platform.isAndroid) return;
    await _plugin.cancel(_notifId(vId));
  }
}
