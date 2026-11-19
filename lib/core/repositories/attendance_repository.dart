import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../database/hive_queue_service.dart';
import '../models/attendance_model.dart';
import '../services/network_service.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final HiveQueueService _queueService;
  final NetworkService _networkService;

  AttendanceRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    required HiveQueueService queueService,
    required NetworkService networkService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _queueService = queueService,
        _networkService = networkService {
    // Sinkronisasi otomatis begitu koneksi internet aktif kembali.
    _networkService.onConnectionChanged.listen((isConnected) {
      if (isConnected) {
        syncPendingQueue();
      }
    });
  }

  // Pencatatan presensi dengan prinsip Offline-First.
  Future<AttendanceModel> recordAttendance(AttendanceModel attendance) async {
    // 1. Simpan selalu ke antrean lokal Hive terlebih dahulu.
    await _queueService.enqueueAttendance(attendance);

    // 2. Periksa ketersediaan jaringan online.
    final isOnline = await _networkService.isConnected();
    if (!isOnline) {
      return attendance.copyWith(syncStatus: 'pending_sync');
    }

    // 3. Jika online, langsung lakukan sinkronisasi ke Firebase.
    try {
      final syncedModel = await _uploadToFirebase(attendance);
      await _queueService.markAsSynced(
        syncedModel.id,
        remotePhotoUrl: syncedModel.photoUrl,
      );
      return syncedModel;
    } catch (_) {
      // Jika upload gagal, status tetap pending_sync di antrean lokal.
      await _queueService.markAsFailed(attendance.id);
      return attendance.copyWith(syncStatus: 'pending_sync');
    }
  }

  // Mengunggah satu record presensi dan fotonya ke Cloud Firestore dan Storage.
  Future<AttendanceModel> _uploadToFirebase(AttendanceModel attendance) async {
    String? photoUrl = attendance.photoUrl;

    // Unggah file foto swafoto jika ada berkas lokalnya.
    if (attendance.photoPath != null && attendance.photoPath!.isNotEmpty) {
      final file = File(attendance.photoPath!);
      if (await file.exists()) {
        try {
          final storageRef = _storage.ref().child(
                'attendances/${attendance.userId}/${attendance.id}_selfie.jpg',
              );
          final uploadTask = await storageRef.putFile(file);
          photoUrl = await uploadTask.ref.getDownloadURL();
        } catch (_) {
          // Graceful fallback: Jika Firebase Storage belum diaktifkan (memerlukan paket Blaze),
          // sinkronisasi data teks & koordinat presensi ke Cloud Firestore tetap berjalan sukses.
        }
      }
    }

    final dataToSave = attendance.toMap();
    dataToSave['photoUrl'] = photoUrl;
    dataToSave['syncStatus'] = 'synced';

    await _firestore.collection('attendances').doc(attendance.id).set(dataToSave);

    return attendance.copyWith(
      photoUrl: photoUrl,
      syncStatus: 'synced',
    );
  }

  // Sinkronisasi seluruh antrean presensi yang tertunda.
  Future<int> syncPendingQueue() async {
    final pendingList = _queueService.getPendingQueue();
    if (pendingList.isEmpty) return 0;

    int successCount = 0;
    for (final item in pendingList) {
      try {
        final syncedItem = await _uploadToFirebase(item);
        await _queueService.markAsSynced(
          syncedItem.id,
          remotePhotoUrl: syncedItem.photoUrl,
        );
        successCount++;
      } catch (_) {
        await _queueService.markAsFailed(item.id);
      }
    }
    return successCount;
  }

  // Mengambil daftar riwayat presensi lokal dan cloud.
  Future<List<AttendanceModel>> getAttendanceHistory(String userId) async {
    // Muat riwayat lokal terlebih dahulu untuk kecepatan tampilan dan resiliensi offline.
    final localList = _queueService.getAllLocalAttendances();

    try {
      final isOnline = await _networkService.isConnected();
      if (isOnline) {
        final snapshot = await _firestore
            .collection('attendances')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(30)
            .get();

        final remoteList = snapshot.docs
            .map((doc) => AttendanceModel.fromMap(doc.data(), documentId: doc.id))
            .toList();

        // Gabungkan tanpa duplikasi ID.
        final Map<String, AttendanceModel> mergedMap = {};
        for (var item in remoteList) {
          mergedMap[item.id] = item;
        }
        for (var item in localList) {
          mergedMap[item.id] = item; // Data lokal menimpa jika statusnya pending_sync
        }

        final result = mergedMap.values.toList();
        result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return result;
      }
    } catch (_) {
      // Gunakan data lokal saat gagal memuat dari Firestore.
    }

    return localList;
  }

  int getPendingCount() => _queueService.pendingCount;
}
