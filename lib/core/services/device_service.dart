import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Menghasilkan identifier unik perangkat keras untuk pengikatan akun NIP.
  Future<String> getUniqueDeviceId() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return 'web_${webInfo.vendor}_${webInfo.userAgent?.hashCode}';
      }

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Menggunakan id perangkat keras Android yang konsisten.
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios_unknown_device';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      }
    } catch (_) {
      // Fallback aman jika pembacaan metadata perangkat gagal.
      return 'fallback_device_${DateTime.now().millisecondsSinceEpoch}';
    }

    return 'generic_device_id';
  }

  // Memverifikasi apakah ID gawai saat ini cocok dengan ID perangkat terdaftar di Firestore.
  Future<bool> verifyDeviceBinding(String registeredDeviceId) async {
    if (registeredDeviceId.isEmpty) {
      // Jika pengguna belum mengikat perangkat, izinkan pendaftaran pertama kali.
      return true;
    }
    final currentId = await getUniqueDeviceId();
    return currentId == registeredDeviceId;
  }
}
