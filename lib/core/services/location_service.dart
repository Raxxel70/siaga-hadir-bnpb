import 'package:geolocator/geolocator.dart';
import '../utils/haversine.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isMocked;
  final double distanceToTarget;
  final bool isWithinGeofence;
  final String? errorMessage;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMocked,
    required this.distanceToTarget,
    required this.isWithinGeofence,
    this.errorMessage,
  });
}

class LocationService {
  // Titik koordinat resmi Graha BNPB Pusat (Jakarta Timur).
  static const double bnpbHqLatitude = -6.2575;
  static const double bnpbHqLongitude = 106.8702;
  static const double defaultGeofenceRadiusMeters = 100.0;

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi (GPS) belum aktif pada perangkat Anda.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin akses lokasi ditolak oleh pengguna.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin akses lokasi ditolak permanen. Buka Pengaturan untuk mengaktifkan.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  // Validasi posisi terhadap mode presensi (WFO / WFH / Lapangan).
  Future<LocationResult> validateAttendanceLocation({
    required String mode,
    double? homeLat,
    double? homeLng,
  }) async {
    try {
      final position = await getCurrentPosition();
      if (position == null) {
        return LocationResult(
          latitude: 0,
          longitude: 0,
          accuracy: 0,
          isMocked: false,
          distanceToTarget: 0,
          isWithinGeofence: false,
          errorMessage: 'Gagal memperoleh koordinat GPS dari perangkat.',
        );
      }

      // Deteksi manipulasi koordinat melalui aplikasi Fake GPS.
      final isMock = position.isMocked;

      double targetLat = bnpbHqLatitude;
      double targetLng = bnpbHqLongitude;
      double allowedRadius = defaultGeofenceRadiusMeters;

      if (mode == 'wfh') {
        targetLat = homeLat ?? bnpbHqLatitude;
        targetLng = homeLng ?? bnpbHqLongitude;
        allowedRadius = 150.0; // Toleransi radius rumah 150 meter.
      } else if (mode == 'field') {
        // Mode tugas darurat TRC menonaktifkan batasan radius kantor.
        allowedRadius = double.infinity;
      }

      final distance = HaversineUtil.calculateDistanceMeters(
        lat1: position.latitude,
        lon1: position.longitude,
        lat2: targetLat,
        lon2: targetLng,
      );

      final isWithin = mode == 'field' || distance <= allowedRadius;

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        isMocked: isMock,
        distanceToTarget: distance,
        isWithinGeofence: isWithin,
      );
    } catch (e) {
      return LocationResult(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        isMocked: false,
        distanceToTarget: 0,
        isWithinGeofence: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
