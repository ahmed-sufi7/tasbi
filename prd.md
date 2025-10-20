# Digital Tasbi - Product Requirements Document (PRD)

## 1. Overview
Digital Tasbi is a modern, iOS-designed mobile application for tracking durood (salawat) and tasbi (dhikr) counts. The app provides a seamless counting experience with cloud synchronization, customization options, and monetization through ads and in-app purchases.

## 2. Core Features

### 2.1 Durood/Tasbi Counter
- **Main Counter Interface**
  - Large, prominent counter display with iOS-style animations
  - Circular progress indicator showing progress toward target
  - Haptic feedback on each count
  - Smooth animations and transitions
  - Target-based counting with customizable goals

- **Counter Actions**
  - Tap to increment count
  - Undo last count
  - Reset counter (with confirmation)
  - Auto-save sessions

### 2.2 Custom Durood Management
- **Pre-loaded Duroods**
  - Durood-e-Ibrahim
  - SubhanAllah
  - Alhamdulillah
  - Allahu Akbar
  - La ilaha illallah

- **Custom Durood Creation**
  - Name field
  - Arabic text field (RTL support)
  - Transliteration field (optional)
  - Translation field (optional)
  - Custom target count
  - Edit and delete custom duroods

### 2.3 History & Statistics
- **Session History**
  - List of all counting sessions
  - Date and time stamps
  - Duration of sessions
  - Completion status
  - Filter by time period (Today, Week, Month, All Time)

- **Statistics Dashboard**
  - Total count across all sessions
  - Completed sessions count
  - Count breakdown by durood type
  - Visual statistics

### 2.4 Notification System
- **Reminder Notifications**
  - Custom notification times
  - Daily recurring reminders
  - Custom messages
  - Enable/disable toggle
  - Vibration settings

- **Completion Notifications**
  - Alert when target is reached
  - Celebration animation
  - Optional sound

### 2.5 Firebase Cloud Messaging (FCM)
- Push notification support
- Topic-based messaging
- Background message handling
- Deep linking support

### 2.6 Theme System
- **Light Theme**
  - Clean, modern color palette
  - Soft purple primary color (#6C63FF)
  - Turquoise secondary color (#4ECDC4)
  - White background (#F8F9FA)

- **Dark Theme**
  - Dark blue background (#1A1A2E)
  - Consistent color accents
  - Easy on the eyes
  - Seamless toggle between themes

### 2.7 Monetization

#### Google AdMob Integration
- Banner ads on main screen
- Interstitial ads after completed sessions
- Non-intrusive ad placement
- Test ads for development

#### In-App Purchase
- One-time purchase to remove all ads
- Price: Set via Google Play Console / App Store Connect
- Restore purchases functionality
- Local verification of purchase status

## 3. Technical Architecture

### 3.1 Technology Stack
- **Framework**: Flutter 3.9+
- **Language**: Dart
- **State Management**: Provider
- **Local Database**: SQLite (sqflite)
- **Local Storage**: SharedPreferences
- **Backend**: Firebase (optional for FCM)

### 3.2 Data Models
- **Durood Model**: id, name, arabic, transliteration, translation, target, isDefault
- **Counter Session Model**: id, duroodId, count, target, startTime, endTime, isCompleted, notes
- **Notification Settings Model**: isEnabled, times, vibrate, sound

### 3.3 Database Schema
```sql
CREATE TABLE duroods (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  arabic TEXT NOT NULL,
  transliteration TEXT,
  translation TEXT,
  target INTEGER NOT NULL,
  isDefault INTEGER NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT
);

CREATE TABLE counter_sessions (
  id TEXT PRIMARY KEY,
  duroodId TEXT NOT NULL,
  count INTEGER NOT NULL,
  target INTEGER NOT NULL,
  startTime TEXT NOT NULL,
  endTime TEXT,
  isCompleted INTEGER NOT NULL,
  notes TEXT,
  FOREIGN KEY (duroodId) REFERENCES duroods (id)
);
```

### 3.4 Services
- **AdService**: Manages banner and interstitial ads
- **NotificationService**: Handles local notifications
- **PurchaseService**: Manages in-app purchases
- **FCMService**: Firebase Cloud Messaging integration

## 4. Design Guidelines

### 4.1 iOS Design Principles
- **Typography**: SF Pro-inspired font stack
- **Spacing**: Consistent 8pt grid system
- **Border Radius**: 12-16pt for cards, 20-24pt for sheets
- **Shadows**: Subtle elevation with soft shadows
- **Animations**: 
  - Bounce/spring animations for interactions
  - Smooth transitions (200-500ms)
  - Scale animations for buttons
  - Fade animations for overlays

### 4.2 Color Palette
```
Light Theme:
- Primary: #6C63FF (Soft Purple)
- Secondary: #4ECDC4 (Turquoise)
- Accent: #FF6B9D (Soft Pink)
- Background: #F8F9FA
- Surface: #FFFFFF
- Text Primary: #2D3436
- Text Secondary: #636E72

Dark Theme:
- Primary: #6C63FF
- Secondary: #4ECDC4
- Accent: #FF6B9D
- Background: #1A1A2E
- Surface: #16213E
- Text Primary: #ECECEC
- Text Secondary: #B2B2B2
```

### 4.3 UI Components
- **CupertinoNavigationBar**: iOS-style app bar
- **CupertinoButton**: iOS-style buttons
- **CupertinoAlertDialog**: iOS-style dialogs
- **Custom Progress Ring**: Animated circular progress
- **Custom Counter Button**: Large, gradient button with shadow
- **Durood Card**: Elevated card with Arabic text

## 5. User Flows

### 5.1 First Launch
1. App opens to main counter screen
2. Default durood pre-selected (Durood-e-Ibrahim)
3. Welcome/tutorial (optional)

### 5.2 Counting Flow
1. User taps counter button
2. Session starts automatically
3. Counter increments with haptic feedback
4. Progress ring updates
5. Target reached → celebration + notification
6. User can continue or save & start new

### 5.3 Custom Durood Creation
1. Navigate to settings/management
2. Tap "Add Custom Durood"
3. Fill in form (name, Arabic, optional fields)
4. Set target count
5. Save
6. New durood appears in selector

### 5.4 Ad-Free Purchase
1. User taps "Remove Ads" in settings
2. Shows product details and price
3. User confirms purchase
4. Payment processed via App Store/Play Store
5. Ads removed immediately
6. Purchase saved locally

## 6. Platform-Specific Configurations

### 6.1 Android Configuration
- `minSdkVersion`: 21
- `compileSdkVersion`: 34
- `targetSdkVersion`: 34
- Required permissions:
  - `INTERNET`
  - `POST_NOTIFICATIONS`
  - `VIBRATE`
  - `BILLING` (for in-app purchases)

### 6.2 iOS Configuration
- `iOS Deployment Target`: 12.0
- Required capabilities:
  - Push Notifications
  - In-App Purchase
- `Info.plist` entries for notifications

## 7. Future Enhancements
- Cloud backup and sync
- Multi-device synchronization
- Social sharing
- Streak tracking
- Achievement system
- Widget support
- Apple Watch companion app
- Export history as PDF
- Multiple languages support

## 8. Performance Requirements
- App launch time: < 2 seconds
- Counter response time: < 50ms
- Smooth 60fps animations
- Database operations: < 100ms
- Low battery consumption

## 9. Security & Privacy
- No personal data collection without consent
- Local-first data storage
- Optional Firebase analytics
- Compliance with GDPR, CCPA
- Transparent privacy policy

## 10. Testing Strategy
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for critical flows
- Manual testing on physical devices
- Ad integration testing
- Purchase flow testing (sandbox)

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Status**: In Development
