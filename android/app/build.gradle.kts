import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadProps(name: String): Properties = 
    Properties().apply {
        val f = rootProject.file(name)
        if (f.exists()) f.inputStream().use { load(it) }
    }

val custom = loadProps("custom.properties")
val key    = loadProps("key.properties")

android {
    namespace = "tw.nfs.flutter.meshsightapp"
    compileSdk = (custom.getProperty("flutter.compileSdkVersion")?.toIntOrNull() ?: flutter.compileSdkVersion)
    ndkVersion = (custom.getProperty("flutter.ndkVersion") ?: flutter.ndkVersion)
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "tw.nfs.flutter.meshsightapp"
        minSdk = (custom.getProperty("flutter.minSdkVersion")?.toIntOrNull() ?: flutter.minSdkVersion)
        targetSdk = (custom.getProperty("flutter.targetSdkVersion")?.toIntOrNull() ?: flutter.targetSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val storeFilePath = key.getProperty("storeFile")
        val storePassword = key.getProperty("storePassword")
        val keyAlias = key.getProperty("keyAlias")
        val keyPassword = key.getProperty("keyPassword")
        
        if (!storeFilePath.isNullOrBlank() &&
            !storePassword.isNullOrBlank() &&
            !keyAlias.isNullOrBlank() &&
            !keyPassword.isNullOrBlank()
        ) {
            create("release") {
                this.storeFile = rootProject.file(storeFilePath)
                this.storePassword = storePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
        }
    }

    buildTypes {
        release {
            if (signingConfigs.findByName("release") != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
