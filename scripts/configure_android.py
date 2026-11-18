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

            # Pastikan minSdk minimal 21 untuk Cloud Firestore & Firebase Auth
            content = re.sub(r'minSdk\s*=\s*.*', 'minSdk = 21', content)
            content = re.sub(r'minSdkVersion\s+.*', 'minSdkVersion 21', content)

            with open(app_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Berhasil memperbarui: {app_file}")
            print(f"--- Cuplikan {app_file} ---")
            print(content[:500])

if __name__ == '__main__':
    configure_android()
