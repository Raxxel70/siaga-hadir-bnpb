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

            with open(app_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Berhasil memperbarui: {app_file}")
            print(f"--- Cuplikan {app_file} ---")
            print(content[:500])

if __name__ == '__main__':
    configure_android()
