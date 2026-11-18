import os
import re

def configure_android():
    # 1. Perbarui android/settings.gradle dengan plugin Google Services
    settings_path = 'android/settings.gradle'
    if os.path.exists(settings_path):
        with open(settings_path, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'com.google.gms.google-services' not in content:
            content = re.sub(
                r'(plugins\s*\{)',
                r'\1\n    id "com.google.gms.google-services" version "4.4.2" apply false',
                content,
                count=1
            )
            with open(settings_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print("Berhasil menambahkan Google Services ke settings.gradle")

    # 2. Terapkan plugin di android/app/build.gradle dan pastikan minSdk >= 21
    app_gradle_path = 'android/app/build.gradle'
    if os.path.exists(app_gradle_path):
        with open(app_gradle_path, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'com.google.gms.google-services' not in content:
            content = re.sub(
                r'(plugins\s*\{)',
                r'\1\n    id "com.google.gms.google-services"',
                content,
                count=1
            )
        # Pastikan minSdk minimal 21 untuk kompatibilitas Cloud Firestore
        content = re.sub(
            r'minSdkVersion\s+flutter\.minSdkVersion',
            'minSdkVersion 21',
            content
        )
        content = re.sub(
            r'minSdk\s*=\s*flutter\.minSdkVersion',
            'minSdk = 21',
            content
        )
        with open(app_gradle_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Berhasil mengonfigurasi android/app/build.gradle")

if __name__ == '__main__':
    configure_android()
