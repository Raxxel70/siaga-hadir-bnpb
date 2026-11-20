import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_model.dart';

class HiveQueueService {
  static const String queueBoxName = 'attendance_offline_queue';
  Box? _box;

  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(queueBoxName)) {
        _box = await Hive.openBox(queueBoxName);
      } else {
        _box = Hive.box(queueBoxName);
      }
    } catch (_) {}
  }

  Box? get _queueBox {
    try {
      if (_box != null && _box!.isOpen) {
        return _box;
      }
      if (Hive.isBoxOpen(queueBoxName)) {
        _box = Hive.box(queueBoxName);
        return _box;
      }
    } catch (_) {}
    return null;
  }

  // Menyimpan record presensi ke antrean lokal saat offline atau sebelum dikirim ke server.
  Future<void> enqueueAttendance(AttendanceModel attendance) async {
    try {
      if (_queueBox == null) {
        await init();
      }
      final box = _queueBox;
      if (box != null) {
        await box.put(attendance.id, attendance.toMap());
      }
    } catch (_) {}
  }

  // Mengambil seluruh presensi yang masih menunggu sinkronisasi (pending_sync).
  List<AttendanceModel> getPendingQueue() {
    final box = _queueBox;
    if (box == null) return [];
    final List<AttendanceModel> pendingList = [];
    try {
      for (var key in box.keys) {
        final data = box.get(key);
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          if (mapData['syncStatus'] == 'pending_sync' || mapData['syncStatus'] == 'failed') {
            pendingList.add(AttendanceModel.fromMap(mapData, documentId: key.toString()));
          }
        }
      }
    } catch (_) {}
    return pendingList;
  }

  // Mengambil semua riwayat yang tersimpan di lokal (termasuk yang sudah tersinkron).
  List<AttendanceModel> getAllLocalAttendances() {
    final box = _queueBox;
    if (box == null) return [];
    final List<AttendanceModel> list = [];
    try {
      for (var key in box.keys) {
        final data = box.get(key);
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          list.add(AttendanceModel.fromMap(mapData, documentId: key.toString()));
        }
      }
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {}
    return list;
  }

  // Memperbarui status sinkronisasi presensi setelah berhasil dikirim ke Cloud Firestore.
  Future<void> markAsSynced(String id, {String? remotePhotoUrl}) async {
    try {
      final box = _queueBox;
      if (box != null) {
        final data = box.get(id);
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          mapData['syncStatus'] = 'synced';
          if (remotePhotoUrl != null) {
            mapData['photoUrl'] = remotePhotoUrl;
          }
          await box.put(id, mapData);
        }
      }
    } catch (_) {}
  }

  // Menandai kegagalan sinkronisasi untuk dicoba kembali nanti.
  Future<void> markAsFailed(String id) async {
    try {
      final box = _queueBox;
      if (box != null) {
        final data = box.get(id);
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          mapData['syncStatus'] = 'failed';
          await box.put(id, mapData);
        }
      }
    } catch (_) {}
  }

  Future<void> remove(String id) async {
    try {
      final box = _queueBox;
      if (box != null) {
        await box.delete(id);
      }
    } catch (_) {}
  }

  int get pendingCount {
    try {
      return getPendingQueue().length;
    } catch (_) {
      return 0;
    }
  }
}
