import os
import re

def configure_android():
    print("Mendeteksi berkas konfigurasi Android...")
    
    # 1. Konfigurasi Settings
    for settings_file in ['android/settings.gradle.kts', 'android/settings.gradle']:
        if os.path.exists(settings_file):
            with open(settings_file, 'r', encoding='utf-8') as f:
                content = f.read()
            if 'com.google.gms.google-services' not in content:
                if settings_file.endswith('.kts'):
                    replacement = r'\1\n    id("com.google.gms.google-services") version "4.4.2" apply false'
                else:
                    replacement = r'\1\n    id "com.google.gms.google-services" version "4.4.2" apply false'
                content = re.sub(r'(plugins\s*\{)', replacement, content, count=1)
                with open(settings_file, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Berhasil memperbarui: {settings_file}")

    # 2. Konfigurasi App Build (Tanpa multiDexEnabled manual yang memicu error Kotlin DSL)
    for app_file in ['android/app/build.gradle.kts', 'android/app/build.gradle']:
        if os.path.exists(app_file):
            with open(app_file, 'r', encoding='utf-8') as f:
                content = f.read()
            if 'com.google.gms.google-services' not in content:
                if app_file.endswith('.kts'):
                    replacement = r'\1\n    id("com.google.gms.google-services")'
                else:
                    replacement = r'\1\n    id "com.google.gms.google-services"'
                content = re.sub(r'(plugins\s*\{)', replacement, content, count=1)
            
            # Pastikan minSdk 21
            content = re.sub(r'minSdk\s*=\s*\d+', 'minSdk = 21', content)
            content = re.sub(r'minSdkVersion\s+\d+', 'minSdkVersion 21', content)
            with open(app_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Berhasil memperbarui: {app_file}")

if __name__ == '__main__':
    configure_android()
