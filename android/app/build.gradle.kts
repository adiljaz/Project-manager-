plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Define the namespace for your app/module
    namespace = "com.example.yelloskye" // Ensure this matches your app's unique namespace
    compileSdk = flutter.compileSdkVersion // Use the SDK version defined by Flutter
    ndkVersion = "27.0.12077973" // Check that this is compatible with your project requirements

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString() // Set JVM target to 11
    }

    defaultConfig {
        applicationId = "com.example.yelloskye" // Unique app ID for your project
        minSdk = 23
        targetSdk = 34 // Ensure this matches your target SDK version
        versionCode = flutter.versionCode // From Flutter's versioning
        versionName = flutter.versionName // From Flutter's versioning
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Set up your release signing key if needed
        }
    }
}

flutter {
    source = "../.." // Path to your Flutter SDK; adjust if necessary
}

 