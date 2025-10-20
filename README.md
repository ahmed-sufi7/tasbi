# Digital Tasbi 📿

A modern, beautifully designed durood and tasbi counter mobile application built with Flutter. Features iOS-inspired design, offline-first architecture, cloud messaging, and monetization support.

![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

## ✨ Features

### Core Functionality
- ✅ **Durood/Tasbi Counter** - Smooth, responsive counter with haptic feedback
- ✅ **Progress Tracking** - Visual circular progress ring with animations
- ✅ **Custom Duroods** - Create and manage your own custom duroods/tasbis
- ✅ **Session History** - Track all your counting sessions with detailed statistics
- ✅ **Smart Notifications** - Customizable daily reminders with FCM support
- ✅ **Dark/Light Theme** - Beautiful iOS-inspired design in both modes
- ✅ **Ad Integration** - Google AdMob banner and interstitial ads
- ✅ **In-App Purchase** - Remove ads with one-time purchase

### Pre-loaded Duroods
1. Durood-e-Ibrahim
2. SubhanAllah (33 times)
3. Alhamdulillah (33 times)
4. Allahu Akbar (34 times)
5. La ilaha illallah

## 🎨 Design

The app follows **iOS design principles** with:
- Clean, modern interface
- Smooth animations and transitions
- Haptic feedback on interactions
- Custom circular progress indicators
- Gradient buttons with shadows
- iOS-style navigation and alerts

### Color Palette
- **Primary**: Soft Purple (#6C63FF)
- **Secondary**: Turquoise (#4ECDC4)
- **Accent**: Soft Pink (#FF6B9D)

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.9+
- **State Management**: Provider
- **Local Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences
- **Backend**: Firebase (FCM only)
- **Ads**: Google Mobile Ads
- **Payments**: In-App Purchase

### Project Structure
```
lib/
├── config/           # App configuration and theme
├── database/         # SQLite database helper
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # Business logic services
├── utils/            # Utility functions
└── widgets/          # Reusable widgets
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase account (for FCM)
- Google AdMob account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/digital-tasbi.git
cd digital-tasbi
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
- Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Add Android and iOS apps to your Firebase project
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Place them in their respective directories:
  - Android: `android/app/google-services.json`
  - iOS: `ios/Runner/GoogleService-Info.plist`

4. **AdMob Setup**
- Create an AdMob account at [AdMob](https://admob.google.com/)
- Create ad units for your app
- Update the Ad Unit IDs in `lib/config/app_config.dart`:
```dart
static const String androidBannerAdUnitId = 'YOUR_ANDROID_BANNER_ID';
static const String iosBannerAdUnitId = 'YOUR_IOS_BANNER_ID';
static const String androidInterstitialAdUnitId = 'YOUR_ANDROID_INTERSTITIAL_ID';
static const String iosInterstitialAdUnitId = 'YOUR_IOS_INTERSTITIAL_ID';
```

5. **Android Configuration**
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

6. **iOS Configuration**
Update `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

7. **In-App Purchase Setup**
- Set up products in Google Play Console (Android)
- Set up products in App Store Connect (iOS)
- Update product ID in `lib/config/app_config.dart`:
```dart
static const String removeAdsProductId = 'your_product_id';
```

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Build APK for Android
flutter build apk --release

# Build iOS app
flutter build ios --release
```

## 📱 Screenshots

*(Add screenshots of your app here)*

## 🔧 Configuration

### Customization

1. **Change App Colors**: Edit `lib/config/app_theme.dart`
2. **Modify Default Duroods**: Edit `lib/config/app_config.dart`
3. **Adjust Animations**: Modify duration in `lib/config/app_config.dart`

### Database

The app uses SQLite for local data storage. Database is automatically created on first launch with:
- `duroods` table for storing durood/tasbi items
- `counter_sessions` table for tracking counting sessions

## 📊 Features Breakdown

### Counter Screen
- Large, tappable counter button with gradient
- Circular progress ring showing completion
- Durood selector with modal sheet
- Action buttons (Undo, Reset)
- Banner ad at bottom (removable via IAP)

### History Screen
- Tabbed interface (Sessions | Statistics)
- Filter by time period
- Session details with duration
- Statistical overview
- Count breakdown by durood type

### Settings Screen
- Dark/Light theme toggle
- Notification preferences
- Multiple notification times
- Remove ads purchase
- Restore purchases
- App information

### Durood Management
- View all custom duroods
- Add new custom durood
- Edit existing durood
- Delete custom durood
- Cannot delete default duroods

## 🎯 Roadmap

- [ ] Cloud backup and sync
- [ ] Multi-device synchronization
- [ ] Social sharing
- [ ] Streak tracking
- [ ] Achievement system
- [ ] Widget support
- [ ] Apple Watch companion
- [ ] Export history as PDF
- [ ] Multiple languages

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google AdMob for monetization
- All contributors and testers

## 📞 Support

For support, email your.email@example.com or create an issue in the repository.

---

**Made with ❤️ and Flutter**
