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
            print("Berhasil menambahkan Google Services ke settings.gradle.kts")
            
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
            print("Berhasil menambahkan Google Services ke settings.gradle (Groovy)")

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
        # Set minSdk = 21 untuk Cloud Firestore
        content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 21', content)
        content = re.sub(r'minSdk\s*=\s*\d+', 'minSdk = 21', content)
        # Aktifkan multiDex
        if 'multiDexEnabled' not in content:
            content = re.sub(
                r'(defaultConfig\s*\{)',
                r'\1\n        multiDexEnabled = true',
                content,
                count=1
            )
        with open(app_kts, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Berhasil mengonfigurasi android/app/build.gradle.kts")
        
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
        # Set minSdk 21
        content = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 21', content)
        content = re.sub(r'minSdkVersion\s+\d+', 'minSdkVersion 21', content)
        content = re.sub(r'minSdk\s*=\s*\d+', 'minSdk = 21', content)
        # Aktifkan multiDex
        if 'multiDexEnabled' not in content:
            content = re.sub(
                r'(defaultConfig\s*\{)',
                r'\1\n        multiDexEnabled true',
                content,
                count=1
            )
        with open(app_groovy, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Berhasil mengonfigurasi android/app/build.gradle (Groovy)")

if __name__ == '__main__':
    configure_android()
