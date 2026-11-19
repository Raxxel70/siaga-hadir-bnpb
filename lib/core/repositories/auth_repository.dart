import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/device_service.dart';

class AuthRepository {
  final FirebaseAuth? _injectedAuth;
  final FirebaseFirestore? _injectedFirestore;
  final DeviceService _deviceService;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    DeviceService? deviceService,
  })  : _injectedAuth = firebaseAuth,
        _injectedFirestore = firestore,
        _deviceService = deviceService ?? DeviceService();

  FirebaseAuth? get _firebaseAuth {
    try {
      return _injectedAuth ?? FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return _injectedFirestore ?? FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Login dengan NIP dan kata sandi, dilanjutkan validasi pengikatan ID perangkat keras.
  Future<UserModel> loginWithNip({
    required String nip,
    required String password,
  }) async {
    final email = '$nip@bnpb.go.id';
    final auth = _firebaseAuth;
    final firestore = _firestore;

    if (auth == null || firestore == null) {
      throw Exception('Layanan autentikasi cloud sedang memuat. Silakan gunakan tombol Uji Lapangan TRC.');
    }

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Identitas autentikasi tidak ditemukan.');
      }

      // Ambil profil pegawai dari Cloud Firestore (pencarian ganda: UID atau NIP).
      DocumentSnapshot<Map<String, dynamic>>? targetDoc;
      final docByUid = await firestore.collection('users').doc(uid).get();
      if (docByUid.exists) {
        targetDoc = docByUid;
      } else {
        final queryByNip = await firestore
            .collection('users')
            .where('nip', isEqualTo: nip)
            .limit(1)
            .get();
        if (queryByNip.docs.isNotEmpty) {
          targetDoc = queryByNip.docs.first;
        }
      }

      if (targetDoc == null || !targetDoc.exists || targetDoc.data() == null) {
        throw Exception('Data kepegawaian NIP $nip belum terdaftar di sistem.');
      }

      final userData = UserModel.fromMap(targetDoc.data()!, documentId: targetDoc.id);
      final currentDeviceId = await _deviceService.getUniqueDeviceId();

      // Pemeriksaan Device Binding.
      if (userData.registeredDeviceId.isEmpty) {
        // Ikat perangkat pada login pertama kali.
        await firestore.collection('users').doc(targetDoc.id).update({
          'registeredDeviceId': currentDeviceId,
        });
        _currentUser = userData.copyWith(registeredDeviceId: currentDeviceId);
      } else if (userData.registeredDeviceId != currentDeviceId) {
        await auth.signOut();
        throw Exception('Akses ditolak: Akun NIP ini telah diikat pada gawai lain.');
      } else {
        _currentUser = userData;
      }

      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('NIP atau kata sandi tidak valid.');
      }
      throw Exception('Gagal melakukan autentikasi: ${e.message}');
    }
  }

  // Login simulasi untuk kebutuhan demonstrasi zona bencana / offline tanpa koneksi awal.
  Future<UserModel> mockLoginOffline({
    required String nip,
    required String name,
    required String role,
  }) async {
    final currentDeviceId = await _deviceService.getUniqueDeviceId();
    _currentUser = UserModel(
      id: 'local_$nip',
      nip: nip,
      name: name,
      email: '$nip@bnpb.go.id',
      role: role,
      registeredDeviceId: currentDeviceId,
      department: role == 'field_trc'
          ? 'Direktorat Kesiapsiagaan BNPB'
          : 'Pusdalops PB Graha BNPB',
      homeLatitude: -6.2088,
      homeLongitude: 106.8456,
    );
    return _currentUser!;
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}
    _currentUser = null;
  }
}
