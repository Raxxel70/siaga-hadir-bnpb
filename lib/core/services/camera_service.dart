import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  // Pengambilan foto swafoto langsung dari kamera depan dengan kompresi optimal untuk Firestore.
  Future<XFile?> captureLiveSelfie() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 60,
        maxWidth: 480,
        maxHeight: 480,
      );
      return photo;
    } catch (_) {
      return null;
    }
  }

  // Pengambilan foto dokumen Surat Perintah Tugas (SPT) untuk mode lapangan TRC.
  Future<XFile?> pickSptDocument() async {
    try {
      final XFile? document = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 60,
        maxWidth: 600,
        maxHeight: 800,
      );
      return document;
    } catch (_) {
      return null;
    }
  }
}
