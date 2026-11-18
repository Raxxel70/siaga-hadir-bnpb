import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/hive_queue_service.dart';
import '../../../core/models/attendance_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/attendance_repository.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/network_service.dart';

final hiveQueueServiceProvider = Provider<HiveQueueService>((ref) {
  return HiveQueueService();
});

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(
    queueService: ref.watch(hiveQueueServiceProvider),
    networkService: ref.watch(networkServiceProvider),
  );
});

class AttendanceState {
  final String selectedMode; // 'wfo', 'wfh', 'field'
  final LocationResult? locationResult;
  final bool isCheckingLocation;
  final bool isSubmitting;
  final int pendingCount;
  final List<AttendanceModel> historyList;
  final bool isLoadingHistory;
  final String? statusMessage;
  final String? errorMessage;

  const AttendanceState({
    this.selectedMode = 'wfo',
    this.locationResult,
    this.isCheckingLocation = false,
    this.isSubmitting = false,
    this.pendingCount = 0,
    this.historyList = const [],
    this.isLoadingHistory = false,
    this.statusMessage,
    this.errorMessage,
  });

  AttendanceState copyWith({
    String? selectedMode,
    LocationResult? locationResult,
    bool? isCheckingLocation,
    bool? isSubmitting,
    int? pendingCount,
    List<AttendanceModel>? historyList,
    bool? isLoadingHistory,
    String? statusMessage,
    String? errorMessage,
  }) {
    return AttendanceState(
      selectedMode: selectedMode ?? this.selectedMode,
      locationResult: locationResult ?? this.locationResult,
      isCheckingLocation: isCheckingLocation ?? this.isCheckingLocation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      pendingCount: pendingCount ?? this.pendingCount,
      historyList: historyList ?? this.historyList,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      statusMessage: statusMessage,
      errorMessage: errorMessage,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;
  final LocationService _locationService;
  final HiveQueueService _queueService;

  AttendanceNotifier({
    required AttendanceRepository repository,
    required LocationService locationService,
    required HiveQueueService queueService,
  })  : _repository = repository,
        _locationService = locationService,
        _queueService = queueService,
        super(const AttendanceState()) {
    _updatePendingCount();
  }

  void _updatePendingCount() {
    state = state.copyWith(pendingCount: _queueService.pendingCount);
  }

  void setMode(String mode, UserModel user) {
    state = state.copyWith(selectedMode: mode, statusMessage: null, errorMessage: null);
    checkLocation(user);
  }

  Future<void> checkLocation(UserModel user) async {
    state = state.copyWith(isCheckingLocation: true, errorMessage: null);
    final result = await _locationService.validateAttendanceLocation(
      mode: state.selectedMode,
      homeLat: user.homeLatitude,
      homeLng: user.homeLongitude,
    );
    state = state.copyWith(
      isCheckingLocation: false,
      locationResult: result,
      errorMessage: result.errorMessage,
    );
  }

  Future<bool> submitAttendance({
    required UserModel user,
    required String? photoPath,
    String? notes,
    String? operationName,
    String? sptDocumentUrl,
  }) async {
    final location = state.locationResult;
    if (location == null) {
      state = state.copyWith(errorMessage: 'Lokasi belum tervalidasi.');
      return false;
    }

    if (location.isMocked) {
      state = state.copyWith(
        errorMessage: 'Aplikasi Fake GPS terdeteksi. Presensi ditolak demi integritas data.',
      );
      return false;
    }

    if (!location.isWithinGeofence && state.selectedMode != 'field') {
      state = state.copyWith(
        errorMessage: 'Presensi gagal: Posisi Anda berada di luar radius yang ditentukan.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final attendance = AttendanceModel(
        id: const Uuid().v4(),
        userId: user.id,
        nip: user.nip,
        userName: user.name,
        mode: state.selectedMode,
        timestamp: DateTime.now(),
        latitude: location.latitude,
        longitude: location.longitude,
        distanceToTarget: location.distanceToTarget,
        isMockLocation: location.isMocked,
        photoPath: photoPath,
        operationName: operationName,
        sptDocumentUrl: sptDocumentUrl,
        notes: notes,
        syncStatus: 'pending_sync',
      );

      final result = await _repository.recordAttendance(attendance);

      _updatePendingCount();
      await loadHistory(user.id);

      final isSynced = result.syncStatus == 'synced';
      state = state.copyWith(
        isSubmitting: false,
        statusMessage: isSynced
            ? 'Presensi berhasil dikirim langsung ke server BNPB.'
            : 'Presensi tersimpan di memori offline perangkat. Akan disinkronkan saat ada sinyal.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal memproses presensi: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> syncNow() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final count = await _repository.syncPendingQueue();
      _updatePendingCount();
      state = state.copyWith(
        isSubmitting: false,
        statusMessage: count > 0
            ? '$count data presensi berhasil disinkronkan ke server.'
            : 'Semua data sudah tersinkronisasi.',
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Sinkronisasi gagal: Periksa koneksi internet Anda.',
      );
    }
  }

  Future<void> loadHistory(String userId) async {
    state = state.copyWith(isLoadingHistory: true);
    final history = await _repository.getAttendanceHistory(userId);
    state = state.copyWith(
      isLoadingHistory: false,
      historyList: history,
    );
  }
}

final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(
    repository: ref.watch(attendanceRepositoryProvider),
    locationService: ref.watch(locationServiceProvider),
    queueService: ref.watch(hiveQueueServiceProvider),
  );
});
