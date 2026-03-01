import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility wrapper around `permission_handler` to request permissions robustly.
class PermissionUtil {
  /// Generic request for a single [permission]. Returns true if granted.
  static Future<bool> request(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    final result = await permission.request();
    if (result.isGranted) return true;

    // If permanently denied, open app settings as last resort.
    if (result.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  /// Request appropriate storage permission(s) for saving to Downloads.
  static Future<bool> requestStorageForDownload() async {
    try {
      if (!Platform.isAndroid) return true;
      if (await _isAndroid10OrHigher()) return true;

      // test request legacy storage (applies to Android 10 and below)
      PermissionStatus status = await Permission.storage.request();
      if (status.isGranted) return true;

      // Android 11+ default storage mayber permanentlyDenied, try manageExternalStorage as fallback.
      if (status.isPermanentlyDenied || await Permission.manageExternalStorage.isRestricted) {
        PermissionStatus manageStatus = await Permission.manageExternalStorage.request();
        if (manageStatus.isGranted) return true;

        // if status is permanently denied, open app settings as last resort.
        if (manageStatus.isPermanentlyDenied) {
          await openAppSettings();
          return false;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check whether storage permission suitable for Downloads is already granted.
  static Future<bool> hasStoragePermissionForDownload() async {
    try {
      if (!Platform.isAndroid) return true;
      if (await Permission.manageExternalStorage.isGranted) return true;
      if (await Permission.storage.isGranted) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _isAndroid10OrHigher() async {
  // Use device_info_plus to check Android version, since permission_handler's API doesn't directly expose this.
  final info = await DeviceInfoPlugin().androidInfo;
  return info.version.sdkInt >= 29;
}
}