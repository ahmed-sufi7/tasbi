# Digital Tasbi - Setup Guide

This guide will help you set up and run the Digital Tasbi app on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (3.9 or higher)
- Dart SDK (3.0 or higher)
- Android Studio (for Android development)
- Xcode (for iOS development - macOS only)
- A Firebase account
- A Google AdMob account

## Step-by-Step Setup

### 1. Install Flutter

If you haven't installed Flutter yet:

**Windows:**
```bash
# Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
# Extract the zip file
# Add flutter\bin to your PATH
```

**macOS:**
```bash
# Using Homebrew
brew install flutter

# Or download from https://docs.flutter.dev/get-started/install/macos
```

**Linux:**
```bash
# Download from https://docs.flutter.dev/get-started/install/linux
# Extract and add to PATH
```

Verify installation:
```bash
flutter doctor
```

### 2. Clone or Download Project

```bash
cd "d:\Desktop\Tasbi counter"
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Digital Tasbi"
4. Disable Google Analytics (optional)
5. Click "Create project"

#### Add Android App
1. Click "Android" icon in Firebase project
2. Android package name: `com.digitaltasbi.digital_tasbi`
3. App nickname: "Digital Tasbi Android"
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

#### Add iOS App (if building for iOS)
1. Click "iOS" icon in Firebase project
2. iOS bundle ID: `com.digitaltasbi.digitalTasbi`
3. App nickname: "Digital Tasbi iOS"
4. Download `GoogleService-Info.plist`
5. Place it in: `ios/Runner/GoogleService-Info.plist`

#### Enable Firebase Cloud Messaging
1. In Firebase Console, go to "Cloud Messaging"
2. No additional setup required for basic messaging

### 5. Google AdMob Setup

#### Create AdMob Account
1. Go to [AdMob](https://admob.google.com/)
2. Sign in with Google account
3. Create new app

#### Create Ad Units
Create the following ad units:
1. **Banner Ad** (320x50)
   - Name: "Main Screen Banner"
2. **Interstitial Ad**
   - Name: "Session Complete Interstitial"

#### Get App IDs and Ad Unit IDs
1. Note your AdMob App ID
2. Note each Ad Unit ID

#### Update Configuration

**For Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<!-- Add inside <application> tag -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

**For iOS** (`ios/Runner/Info.plist`):
```xml
<!-- Add before </dict> -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

**Update Ad Unit IDs** (`lib/config/app_config.dart`):
```dart
// Replace with your actual Ad Unit IDs
static const String androidBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String iosBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String androidInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
static const String iosInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
```

**Note:** For testing, the current test IDs in the code will work fine.

### 6. In-App Purchase Setup

#### Android (Google Play Console)
1. Create app in [Google Play Console](https://play.google.com/console)
2. Go to "Monetize" > "In-app products"
3. Create managed product:
   - Product ID: `remove_ads_premium`
   - Name: "Remove Ads Premium"
   - Description: "Remove all advertisements"
   - Price: Set your price

#### iOS (App Store Connect)
1. Create app in [App Store Connect](https://appstoreconnect.apple.com/)
2. Go to "Features" > "In-App Purchases"
3. Create non-consumable IAP:
   - Product ID: `remove_ads_premium`
   - Reference Name: "Remove Ads Premium"
   - Price: Set your price

#### Update Product ID (if different)
In `lib/config/app_config.dart`:
```dart
static const String removeAdsProductId = 'your_product_id';
```

### 7. Android-Specific Setup

#### Update gradle.properties
File: `android/gradle.properties`
```properties
org.gradle.jvmargs=-Xmx4096M -Dkotlin.daemon.jvm.options\="-Xmx4096M"
android.useAndroidX=true
android.enableJetifier=true
```

#### Update build.gradle (app level)
File: `android/app/build.gradle.kts`
Ensure these are present:
```kotlin
android {
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.digitaltasbi.digital_tasbi"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging")
}
```

#### Add Firebase plugin
File: `android/app/build.gradle.kts` (at the end):
```kotlin
apply(plugin = "com.google.gms.google-services")
```

File: `android/build.gradle.kts`:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### 8. iOS-Specific Setup (macOS only)

#### Install CocoaPods
```bash
sudo gem install cocoapods
```

#### Install iOS dependencies
```bash
cd ios
pod install
cd ..
```

#### Update Info.plist
File: `ios/Runner/Info.plist`
Add permissions:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera</string>
<key>NSUserNotificationsUsageDescription</key>
<string>We need to send you reminders</string>
```

### 9. Run the App

#### On Android Emulator/Device
```bash
flutter run
```

#### On iOS Simulator/Device (macOS only)
```bash
flutter run -d ios
```

#### Build Release APK (Android)
```bash
flutter build apk --release
```

#### Build Release IPA (iOS)
```bash
flutter build ios --release
```

### 10. Testing

#### Test Ads
The app uses test ad IDs by default. You should see ads with "Test Ad" label.

#### Test Notifications
1. Go to Settings
2. Enable notifications
3. Add notification time
4. Wait for the scheduled time
5. You should receive a notification

#### Test In-App Purchase
For testing IAP, you need:
- **Android:** Set up test account in Google Play Console
- **iOS:** Set up Sandbox tester in App Store Connect

### 11. Common Issues & Solutions

#### Issue: Firebase not initialized
**Solution:** Make sure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location.

#### Issue: Ads not showing
**Solution:** 
- Verify AdMob app ID in AndroidManifest.xml / Info.plist
- Check internet connection
- For production, replace test ad IDs with real ones

#### Issue: Build fails on iOS
**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

#### Issue: Notification not working
**Solution:**
- Check device notification permissions
- Ensure notification service is initialized
- For Android, check notification channel

### 12. Deployment

#### Android Deployment
1. Generate signing key
2. Update `android/app/build.gradle.kts` with signing config
3. Build release APK: `flutter build apk --release`
4. Upload to Google Play Console

#### iOS Deployment
1. Configure signing in Xcode
2. Build release: `flutter build ios --release`
3. Archive and upload via Xcode
4. Submit to App Store Connect

### 13. Maintenance

#### Update Dependencies
```bash
flutter pub upgrade
```

#### Check for Issues
```bash
flutter doctor
flutter analyze
```

### 14. Support

If you encounter any issues:
1. Check the documentation
2. Search existing issues on GitHub
3. Create a new issue with details
4. Contact support

---

**Happy Coding! 📱✨**
