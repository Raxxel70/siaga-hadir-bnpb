import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_model.dart';

class HiveQueueService {
  static const String queueBoxName = 'attendance_offline_queue';
  Box? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(queueBoxName)) {
      _box = await Hive.openBox(queueBoxName);
    } else {
      _box = Hive.box(queueBoxName);
    }
  }

  Box get _queueBox {
    if (_box == null || !_box!.isOpen) {
      return Hive.box(queueBoxName);
    }
    return _box!;
  }

  // Menyimpan record presensi ke antrean lokal saat offline atau sebelum dikirim ke server.
  Future<void> enqueueAttendance(AttendanceModel attendance) async {
    final map = attendance.toMap();
    await _queueBox.put(attendance.id, map);
  }

  // Mengambil seluruh presensi yang masih menunggu sinkronisasi (pending_sync).
  List<AttendanceModel> getPendingQueue() {
    final List<AttendanceModel> pendingList = [];
    for (var key in _queueBox.keys) {
      final data = _queueBox.get(key);
      if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        if (mapData['syncStatus'] == 'pending_sync' || mapData['syncStatus'] == 'failed') {
          pendingList.add(AttendanceModel.fromMap(mapData, documentId: key.toString()));
        }
      }
    }
    return pendingList;
  }

  // Mengambil semua riwayat yang tersimpan di lokal (termasuk yang sudah tersinkron).
  List<AttendanceModel> getAllLocalAttendances() {
    final List<AttendanceModel> list = [];
    for (var key in _queueBox.keys) {
      final data = _queueBox.get(key);
      if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        list.add(AttendanceModel.fromMap(mapData, documentId: key.toString()));
      }
    }
    // Urutkan dari yang terbaru
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  // Memperbarui status sinkronisasi presensi setelah berhasil dikirim ke Cloud Firestore.
  Future<void> markAsSynced(String id, {String? remotePhotoUrl}) async {
    final data = _queueBox.get(id);
    if (data is Map) {
      final mapData = Map<String, dynamic>.from(data);
      mapData['syncStatus'] = 'synced';
      if (remotePhotoUrl != null) {
        mapData['photoUrl'] = remotePhotoUrl;
      }
      await _queueBox.put(id, mapData);
    }
  }

  // Menandai kegagalan sinkronisasi untuk dicoba kembali nanti.
  Future<void> markAsFailed(String id) async {
    final data = _queueBox.get(id);
    if (data is Map) {
      final mapData = Map<String, dynamic>.from(data);
      mapData['syncStatus'] = 'failed';
      await _queueBox.put(id, mapData);
    }
  }

  Future<void> remove(String id) async {
    await _queueBox.delete(id);
  }

  int get pendingCount {
    return getPendingQueue().length;
  }
}
