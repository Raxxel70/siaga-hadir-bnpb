import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  // Pengambilan foto swafoto langsung dari kamera depan perangkat.
  Future<XFile?> captureLiveSelfie() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1280,
        maxHeight: 1280,
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
        imageQuality: 90,
      );
      return document;
    } catch (_) {
      return null;
    }
  }
}
