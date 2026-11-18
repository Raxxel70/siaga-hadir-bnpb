# Required Skills & Tools: SIAGA-HADIR (Firebase Stack)

To build, deploy, and generate the APK for **SIAGA-HADIR**, master the following tools and packages:

## 1. Core Development Tools
* **Flutter SDK & Dart:** Cross-platform mobile app framework.
* **Android Studio / VS Code:** IDEs with Flutter and Firebase extensions.
* **Firebase Console:** For managing Authentication, Cloud Firestore, and Firebase Storage.

## 2. Essential Flutter Packages (`pubspec.yaml`)
* `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`: Core Firebase services.
* `geolocator` & `geocoding`: GPS coordinates and address lookup.
* `hive` or `sqflite`: Local database for *Offline-First* queueing.
* `camera` or `image_picker`: Live selfie capture.
* `device_info_plus`: Unique hardware ID for *Device ID Binding*.
* `connectivity_plus`: Network status monitoring for automatic background sync.

## 3. Core Technical Concepts
* **Haversine Formula:** Mathematical distance calculations in Dart for Geofencing.
* **APK Build Process:** Executing `flutter build apk --release` to generate the installable Android package.