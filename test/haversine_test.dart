import 'package:flutter_test/flutter_test.dart';
import 'package:siaga_hadir/core/utils/haversine.dart';

void main() {
  group('Pengujian Rumus Geofencing Haversine (Graha BNPB)', () {
    // Titik Graha BNPB Jakarta Timur (-6.2575, 106.8702)
    const double bnpbLat = -6.2575;
    const double bnpbLon = 106.8702;

    test('Jarak antar koordinat identik harus 0 meter', () {
      final distance = HaversineUtil.calculateDistanceMeters(
        lat1: bnpbLat,
        lon1: bnpbLon,
        lat2: bnpbLat,
        lon2: bnpbLon,
      );
      expect(distance, equals(0.0));
    });

    test('Deteksi koordinat di dalam radius 100 meter kantor BNPB', () {
      // Titik sekitar 30 meter di halaman Graha BNPB
      const double nearLat = -6.2573;
      const double nearLon = 106.8704;

      final isWithin = HaversineUtil.isWithinRadius(
        currentLat: nearLat,
        currentLon: nearLon,
        targetLat: bnpbLat,
        targetLon: bnpbLon,
        maxRadiusMeters: 100.0,
      );

      final distance = HaversineUtil.calculateDistanceMeters(
        lat1: nearLat,
        lon1: nearLon,
        lat2: bnpbLat,
        lon2: bnpbLon,
      );

      expect(isWithin, isTrue);
      expect(distance, lessThanOrEqualTo(100.0));
    });

    test('Deteksi koordinat di luar radius 100 meter (penolakan WFO)', () {
      // Titik sekitar 1.2 kilometer dari kantor BNPB
      const double farLat = -6.2480;
      const double farLon = 106.8750;

      final isWithin = HaversineUtil.isWithinRadius(
        currentLat: farLat,
        currentLon: farLon,
        targetLat: bnpbLat,
        targetLon: bnpbLon,
        maxRadiusMeters: 100.0,
      );

      expect(isWithin, isFalse);
    });
  });
}
