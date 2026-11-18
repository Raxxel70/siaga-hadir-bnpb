import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCUclORBLd-R_oudFJrCXcKyZt5tdxNMSw',
    appId: '1:201077736919:web:siagahadirbnpbweb',
    messagingSenderId: '201077736919',
    projectId: 'siaga-hadir-bnpb',
    authDomain: 'siaga-hadir-bnpb.firebaseapp.com',
    storageBucket: 'siaga-hadir-bnpb.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUclORBLd-R_oudFJrCXcKyZt5tdxNMSw',
    appId: '1:201077736919:android:08cfd5395c58b50f797792',
    messagingSenderId: '201077736919',
    projectId: 'siaga-hadir-bnpb',
    storageBucket: 'siaga-hadir-bnpb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUclORBLd-R_oudFJrCXcKyZt5tdxNMSw',
    appId: '1:201077736919:ios:siagahadirbnpbios',
    messagingSenderId: '201077736919',
    projectId: 'siaga-hadir-bnpb',
    storageBucket: 'siaga-hadir-bnpb.firebasestorage.app',
    iosBundleId: 'com.bnpb.siagaHadir',
  );
}
