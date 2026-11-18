import os
import re

def configure_android():
    print("Mendeteksi berkas konfigurasi Android...")

    # 1. Konfigurasi Settings (Groovy atau Kotlin DSL)
    settings_kts = 'android/settings.gradle.kts'
    settings_groovy = 'android/settings.gradle'

    if os.path.exists(settings_kts):
        with open(settings_kts, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'com.google.gms.google-services' not in content:
            content = re.sub(
                r'(plugins\s*\{)',
                r'\1\n    id("com.google.gms.google-services") version "4.4.2" apply false',
                content,
                count=1
            )
            with open(settings_kts, 'w', encoding='utf-8') as f:
                f.write(content)
            print("Berhasil memperbarui settings.gradle.kts dengan plugin Google Services")

    elif os.path.exists(settings_groovy):
        with open(settings_groovy, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'com.google.gms.google-services' not in content:
            content = re.sub(
                r'(plugins\s*\{)',
                r'\1\n    id "com.google.gms.google-services" version "4.4.2" apply false',
                content,
                count=1
            )
            with open(settings_groovy, 'w', encoding='utf-8') as f:
                f.write(content)
            print("Berhasil memperbarui settings.gradle (Groovy) dengan plugin Google Services")

    # 2. Konfigurasi App Build (Groovy atau Kotlin DSL)
    app_kts = 'android/app/build.gradle.kts'
    app_groovy = 'android/app/build.gradle'

    if os.path.exists(app_kts):
        with open(app_kts, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'com.google.gms.google-services' not in content:
            content = re.sub(
                r'(plugins\s*\{)',
                r'\1\n    id("com.google.gms.google-services")',
                content,
                count=1
            )
        # Mengubah minSdk menjadi 21 (wajib untuk Cloud Firestore dan Firebase Auth)
        content = re.sub(r'minSdk\s*=\s*.*', 'minSdk = 21', content)
        with open(app_kts, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Berhasil memperbarui android/app/build.gradle.kts (minSdk = 21)")
        print("--- Isi android/app/build.gradle.kts ---")
        print(content[:500])

    elif os.path.exists(app_groovy):
        with open(app_groovy, 'r', encoding='utf-8') as f:
            content = f.read()
        if 'com.google.gms.google-services' not in content:
            content = re.sub(
                r'(plugins\s*\{)',
                r'\1\n    id "com.google.gms.google-services"',
                content,
                count=1
            )
        # Mengubah minSdkVersion menjadi 21
        content = re.sub(r'minSdkVersion\s+.*', 'minSdkVersion 21', content)
        content = re.sub(r'minSdk\s*=\s*.*', 'minSdk = 21', content)
        with open(app_groovy, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Berhasil memperbarui android/app/build.gradle (minSdkVersion 21)")

if __name__ == '__main__':
    configure_android()
