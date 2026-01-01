import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PlatformInfo {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get the current platform name (Android, iOS, etc.)
  static String getPlatformName() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  /// Get device model information
  static Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        // Use name if available, otherwise use machine identifier
        return iosInfo.name.isNotEmpty ? iosInfo.name : iosInfo.utsname.machine;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await _deviceInfo.macOsInfo;
        return macInfo.computerName;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await _deviceInfo.linuxInfo;
        return linuxInfo.name;
      }
    } catch (e) {
      // Return fallback if there's an error
      return 'Unknown Device';
    }
    return 'Unknown Device';
  }

  /// Get both platform and device info as a map
  static Future<Map<String, String>> getPlatformAndDeviceInfo() async {
    final platform = getPlatformName();
    final device = await getDeviceModel();
    
    return {
      'platform': platform,
      'device': device,
    };
  }
}