#!/bin/bash
set -e
echo "🔧 Generating Android v2 embedding structure..."

# Clean & create directories
rm -rf android/
mkdir -p android/app/src/main/kotlin/com/example/edu_archive_app
mkdir -p android/app/src/main/res/{values,drawable,mipmap-hdpi,mipmap-mdpi,mipmap-xhdpi,mipmap-xxhdpi,mipmap-xxxhdpi}
mkdir -p android/gradle/wrapper

# 1. settings.gradle
cat > android/settings.gradle << 'EOF'
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.1.0" apply false
    id "org.jetbrains.kotlin.android" version "1.8.22" apply false
}
include ":app"
EOF

# 2. root build.gradle
cat > android/build.gradle << 'EOF'
allprojects { repositories { google(); mavenCentral() } }
rootProject.buildDir = "../build"
subprojects { project.buildDir = "${rootProject.buildDir}/${project.name}" }
subprojects { project.evaluationDependsOn(":app") }
tasks.register("clean", Delete) { delete rootProject.buildDir }
EOF

# 3. gradle.properties
cat > android/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
EOF

# 4. gradle-wrapper.properties
cat > android/gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
EOF

# 5. app/build.gradle
cat > android/app/build.gradle << 'EOF'
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}
android {
    namespace = "com.example.edu_archive_app"
    compileSdk = 34
    compileOptions { sourceCompatibility = JavaVersion.VERSION_1_8; targetCompatibility = JavaVersion.VERSION_1_8 }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_1_8 }
    defaultConfig {
        applicationId = "com.example.edu_archive_app"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    buildTypes { release { signingConfig = signingConfigs.debug } }
}
flutter { source = "../.." }
EOF

# 6. AndroidManifest.xml
cat > android/app/src/main/AndroidManifest.xml << 'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="EduArchive"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data android:name="io.flutter.embedding.android.NormalTheme" android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
EOF

# 7. MainActivity.kt
cat > android/app/src/main/kotlin/com/example/edu_archive_app/MainActivity.kt << 'EOF'
package com.example.edu_archive_app
import io.flutter.embedding.android.FlutterActivity
class MainActivity: FlutterActivity()
EOF

# 8. Minimal Resource Files
cat > android/app/src/main/res/values/styles.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
EOF

cat > android/app/src/main/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">EduArchive</string>
</resources>
EOF

cat > android/app/src/main/res/drawable/launch_background.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
</layer-list>
EOF

# Create placeholder launcher icons (1x1 transparent PNG)
ICON="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
echo "$ICON" | base64 -d > android/app/src/main/res/mipmap-hdpi/ic_launcher.png
cp android/app/src/main/res/mipmap-hdpi/ic_launcher.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
cp android/app/src/main/res/mipmap-hdpi/ic_launcher.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
cp android/app/src/main/res/mipmap-hdpi/ic_launcher.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
cp android/app/src/main/res/mipmap-hdpi/ic_launcher.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

echo "✅ Android v2 structure generated successfully!"