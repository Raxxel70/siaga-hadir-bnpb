import 'package:flutter_test/flutter_test.dart';
import 'package:siaga_hadir/core/models/attendance_model.dart';

void main() {
  group('Pengujian Model Presensi Offline-First', () {
    test('Serialisasi toMap dan deserialisasi fromMap mempertahankan data', () {
      final now = DateTime.now();
      final model = AttendanceModel(
        id: 'att_001',
        userId: 'usr_123',
        nip: '199208142018011003',
        userName: 'Rizki Pratama',
        mode: 'field',
        timestamp: now,
        latitude: -0.3812,
        longitude: 100.4632,
        distanceToTarget: 0.0,
        isMockLocation: false,
        photoPath: '/storage/selfie.jpg',
        operationName: 'Tanggap Darurat Banjir Bandang',
        syncStatus: 'pending_sync',
      );

      final map = model.toMap();
      final parsed = AttendanceModel.fromMap(map, documentId: 'att_001');

      expect(parsed.id, equals('att_001'));
      expect(parsed.nip, equals('199208142018011003'));
      expect(parsed.mode, equals('field'));
      expect(parsed.operationName, equals('Tanggap Darurat Banjir Bandang'));
      expect(parsed.syncStatus, equals('pending_sync'));
      expect(parsed.isMockLocation, isFalse);
    });

    test('Perubahan status sinkronisasi melalui copyWith', () {
      final model = AttendanceModel(
        id: 'att_002',
        userId: 'usr_456',
        nip: '198705202010121002',
        userName: 'Budi Santoso',
        mode: 'wfo',
        timestamp: DateTime.now(),
        latitude: -6.2575,
        longitude: 106.8702,
        distanceToTarget: 15.0,
        isMockLocation: false,
        syncStatus: 'pending_sync',
      );

      final synced = model.copyWith(
        syncStatus: 'synced',
        photoUrl: 'https://firebasestorage.googleapis.com/v0/b/demo/o/selfie.jpg',
      );

      expect(synced.syncStatus, equals('synced'));
      expect(synced.photoUrl, isNotNull);
    });
  });
}
