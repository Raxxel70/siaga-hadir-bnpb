import 'dart:math';

class HaversineUtil {
  // Radius ekuator bumi dalam satuan meter.
  static const double earthRadiusMeters = 6371000.0;

  // Menghitung jarak geodesic dua koordinat dalam satuan meter.
  static double calculateDistanceMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degree) => degree * (pi / 180.0);

  // Validasi apakah koordinat gawai berada di dalam batas radius maksimal yang diizinkan.
  static bool isWithinRadius({
    required double currentLat,
    required double currentLon,
    required double targetLat,
    required double targetLon,
    required double maxRadiusMeters,
  }) {
    final distance = calculateDistanceMeters(
      lat1: currentLat,
      lon1: currentLon,
      lat2: targetLat,
      lon2: targetLon,
    );
    return distance <= maxRadiusMeters;
  }
}
