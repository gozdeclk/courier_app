plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // 1. ADIM: Google Services plugin'ini buraya ekle (Versiyon yazmadan ve apply false demeden)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.gozde.courier_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.gozde.courier_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (Bill of Materials) - Versiyonları yönetir
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))

    // Kullanmak istediğin Firebase servislerini ekle
    implementation("com.google.firebase:firebase-analytics")
    
    // Kurye takip projesi için ileride şunları da buraya ekleyebilirsin:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}