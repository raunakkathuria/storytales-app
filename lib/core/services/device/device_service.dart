import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// Service for managing device identification and information.
class DeviceService {
  static const String _deviceIdKey = 'device_id';
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Gets or creates a unique device identifier.
  ///
  /// This method first checks if a device ID is already stored locally.
  /// If not, it generates a new one based on device information and stores it.
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we already have a stored device ID
    String? storedDeviceId = prefs.getString(_deviceIdKey);
    if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
      return storedDeviceId;
    }

    // Generate a new device ID
    final deviceId = await _generateDeviceId();

    // Store it for future use
    await prefs.setString(_deviceIdKey, deviceId);

    return deviceId;
  }

  /// Generates a unique device identifier based on device information.
  Future<String> _generateDeviceId() async {
    try {
      String deviceInfo = '';

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceInfo = '${androidInfo.model}-${androidInfo.id}-${androidInfo.fingerprint}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceInfo = '${iosInfo.model}-${iosInfo.identifierForVendor}-${iosInfo.systemVersion}';
      } else {
        // Fallback for other platforms
        deviceInfo = 'unknown-platform-${DateTime.now().millisecondsSinceEpoch}';
      }

      // Create a hash of the device info for consistent device identification
      final bytes = utf8.encode(deviceInfo);
      final digest = sha256.convert(bytes);

      // Return a shorter, more manageable device ID
      return 'device-${digest.toString().substring(0, 16)}';
    } catch (e) {
      // Fallback to timestamp-based ID if device info fails
      // This ensures some consistency within the same session
      final fallbackInfo = 'fallback-${Platform.operatingSystem}';
      final bytes = utf8.encode(fallbackInfo);
      final digest = sha256.convert(bytes);
      return 'device-${digest.toString().substring(0, 16)}';
    }
  }

  /// Gets detailed device information for debugging purposes.
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      } else {
        return {
          'platform': 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      return {
        'platform': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Clears the stored device ID (useful for testing or reset scenarios).
  Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }
}
