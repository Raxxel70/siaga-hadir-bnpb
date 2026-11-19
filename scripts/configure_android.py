import os
import re

def configure_android():
    print("Mendeteksi berkas konfigurasi Android...")

    # 1. Konfigurasi Settings (Kotlin DSL atau Groovy)
    for settings_file in ['android/settings.gradle.kts', 'android/settings.gradle']:
        if os.path.exists(settings_file):
            with open(settings_file, 'r', encoding='utf-8') as f:
                content = f.read()
            if 'com.google.gms.google-services' not in content:
                if settings_file.endswith('.kts'):
                    line = '    id("com.google.gms.google-services") version "4.4.2" apply false\n'
                else:
                    line = '    id "com.google.gms.google-services" version "4.4.2" apply false\n'
                content = re.sub(r'(plugins\s*\{[\s\S]*?)(\})', r'\g<1>' + line + r'\2', content, count=1)

            # Nonaktifkan lintVital pada seluruh subproyek (seperti image_picker_android)
            if 'lintVital' not in content:
                if settings_file.endswith('.kts'):
                    content += '\ngradle.beforeProject {\n    tasks.configureEach {\n        if (name.contains("lintVital", ignoreCase = true)) {\n            enabled = false\n        }\n    }\n}\n'
                else:
                    content += '\ngradle.beforeProject { project ->\n    project.tasks.configureEach { task ->\n        if (task.name.toLowerCase().contains("lintvital")) {\n            task.enabled = false\n        }\n    }\n}\n'

            with open(settings_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Berhasil memperbarui: {settings_file}")

    # 2. Konfigurasi App Build (Wajib ditaruh SETELAH com.android.application)
    for app_file in ['android/app/build.gradle.kts', 'android/app/build.gradle']:
        if os.path.exists(app_file):
            with open(app_file, 'r', encoding='utf-8') as f:
                content = f.read()
            if 'com.google.gms.google-services' not in content:
                if app_file.endswith('.kts'):
                    line = '    id("com.google.gms.google-services")\n'
                else:
                    line = '    id "com.google.gms.google-services"\n'
                content = re.sub(r'(plugins\s*\{[\s\S]*?)(\})', r'\g<1>' + line + r'\2', content, count=1)

            # Nonaktifkan lint check pada rilis build
            if app_file.endswith('.kts'):
                if 'checkReleaseBuilds' not in content:
                    content = re.sub(
                        r'(android\s*\{)',
                        r'\1\n    lint {\n        checkReleaseBuilds = false\n        abortOnError = false\n    }',
                        content,
                        count=1
                    )
            else:
                if 'checkReleaseBuilds' not in content:
                    content = re.sub(
                        r'(android\s*\{)',
                        r'\1\n    lintOptions {\n        checkReleaseBuilds false\n        abortOnError false\n    }',
                        content,
                        count=1
                    )

            # Pastikan minSdk minimal 21 untuk Cloud Firestore & Firebase Auth
            content = re.sub(r'minSdk\s*=\s*.*', 'minSdk = 21', content)
            content = re.sub(r'minSdkVersion\s+.*', 'minSdkVersion 21', content)

            # Pastikan applicationId dan namespace sesuai com.bnpb.siaga_hadir
            content = re.sub(r'applicationId\s*=\s*.*', 'applicationId = "com.bnpb.siaga_hadir"', content)
            content = re.sub(r'applicationId\s+"[^"]+"', 'applicationId "com.bnpb.siaga_hadir"', content)
            content = re.sub(r'namespace\s*=\s*.*', 'namespace = "com.bnpb.siaga_hadir"', content)
            content = re.sub(r'namespace\s+"[^"]+"', 'namespace "com.bnpb.siaga_hadir"', content)

            with open(app_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Berhasil memperbarui: {app_file}")

    # 3. Konfigurasi AndroidManifest.xml (Izin Kamera, GPS, dan Jaringan)
    manifest_path = 'android/app/src/main/AndroidManifest.xml'
    if os.path.exists(manifest_path):
        with open(manifest_path, 'r', encoding='utf-8') as f:
            manifest = f.read()

        permissions = """
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-feature android:name="android.hardware.camera" android:required="false"/>
    <uses-feature android:name="android.hardware.location.gps" android:required="true"/>
"""
        if 'android.permission.INTERNET' not in manifest:
            manifest = re.sub(r'(<manifest[^>]*>)', r'\1\n' + permissions, manifest, count=1)

        manifest = re.sub(r'android:label="[^"]*"', 'android:label="SIAGA-HADIR"', manifest)

        with open(manifest_path, 'w', encoding='utf-8') as f:
            f.write(manifest)
        print("Berhasil memperbarui AndroidManifest.xml dengan seluruh izin operasional.")

    # 4. Konfigurasi styles.xml (Mencegah Layar Hitam pada Launch Native)
    styles_dir = 'android/app/src/main/res/values'
    styles_path = os.path.join(styles_dir, 'styles.xml')
    if os.path.exists(styles_path):
        with open(styles_path, 'r', encoding='utf-8') as f:
            styles = f.read()
        styles = styles.replace('@android:style/Theme.Black.NoTitleBar', '@android:style/Theme.Light.NoTitleBar')
        with open(styles_path, 'w', encoding='utf-8') as f:
            f.write(styles)
        print("Berhasil memperbarui styles.xml dengan latar belakang terang.")

if __name__ == '__main__':
    configure_android()
