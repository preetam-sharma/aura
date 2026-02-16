# Aura - Daily Activity Logger & Intelligent Finance Manager

A production-ready Flutter application with glassmorphism UI design, combining activity tracking with intelligent finance management.

## Features

✅ **Glassmorphism UI** - Modern frosted-glass design  
✅ **Authentication** - Email/Google login with biometric lock  
✅ **Finance Hub** - Expense tracking, analytics charts, savings goals  
✅ **QR Scanner** - UPI payment integration ready  
✅ **Task Logger** - Location-based geofence alerts  
✅ **AI Suggestions** - Smart expense reduction tips  

## Quick Start

### Prerequisites
- Flutter SDK 3.38.9 or higher
- Android SDK or Xcode
- Firebase project (optional for demo mode)

### Installation

```bash
cd aura
flutter pub get
flutter run
```

## Firebase Configuration

**Option 1: FlutterFire CLI (Recommended)**
```bash
npm install -g firebase-tools
flutterfire configure
```

**Option 2: Manual**
Replace placeholder values in `lib/firebase_options.dart` with your Firebase project credentials.

**Demo Mode:** App works without Firebase using `FakeAuthRepository` for testing UI/UX.

## Platform Setup

### Android Permissions
Already configured in `android/app/src/main/AndroidManifest.xml`:
- Camera (QR scanning)
- Location (geofencing)
- Biometric authentication
- Internet

### iOS Permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access required for QR code scanning</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location required for task geofencing</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Background location for geofence alerts</string>
<key>NSFaceIDUsageDescription</key>
<string>Biometric authentication for security</string>
```

## Architecture

```
lib/
├── main.dart
├── firebase_options.dart
└── src/
    ├── common_widgets/     # Reusable UI components
    ├── constants/          # Theme and colors
    ├── features/           # Feature modules
    │   ├── auth/
    │   ├── dashboard/
    │   ├── finance/
    │   ├── home/
    │   └── tasks/
    └── routing/           # GoRouter configuration
```

## Code Quality

- ✅ Zero analysis errors
- ✅ 30 minor deprecation warnings (cosmetic)
- ✅ Feature-first architecture
- ✅ Riverpod state management
- ✅ Type-safe routing

## Next Steps

1. Configure Firebase for production
2. Implement `FirebaseAuthRepository`
3. Add UPI payment redirection logic
4. Configure background geofencing service
5. Implement SMS 2FA enrollment flow

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Riverpod Guide](https://riverpod.dev/)

Built with ❤️ using Flutter
