import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermission {
  final DeviceInfoPlugin _deviceInfoPlugin;
  StoragePermission(
    this._deviceInfoPlugin,
  );
  //request
  Future<bool> get requestStoragePermission async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 33) {
        final audio = await Permission.audio.request();
        return audio.isGranted;
      } else {
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    } else {
      return true;
    }
  }

  //check
  Future<bool> get checkStoragePermissionStatus async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 33) {
        return await Permission.audio.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else {
      return true;
    }
  }
}
