# Firebase Setup Guide for Triva Flutter App

## Configuration Files Placement

### Android Configuration
1. Download the `google-services.json` file from your Firebase console
2. Place it in: `/Users/mac/Documents/projects/flutter_default_template/android/app/`

### iOS Configuration
1. Download the `GoogleService-Info.plist` file from your Firebase console
2. Place it in: `/Users/mac/Documents/projects/flutter_default_template/ios/Runner/`
3. Make sure to add it to your Xcode project by dragging the file into the Runner directory with Xcode open

## Update Firebase Options

After placing the configuration files, update the placeholder values in:
`/Users/mac/Documents/projects/flutter_default_template/lib/firebase_options.dart`

Replace the placeholder values with the actual values from your Firebase console:
- apiKey
- appId
- messagingSenderId
- projectId
- storageBucket
- iosClientId (for iOS)
- iosBundleId (for iOS)

## Android Setup

1. Make sure your app's `minSdkVersion` is at least 19 (or 21 for Android App Bundles)
2. Verify that the applicationId in `android/app/build.gradle` matches the Android package name you registered in Firebase

## iOS Setup

1. Ensure the iOS bundle ID in your Xcode project matches the one you registered in Firebase
2. Add the following to your `ios/Runner/Info.plist` if you plan to use Firebase Authentication:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>REVERSED_CLIENT_ID_FROM_GOOGLESERVICE_INFO_PLIST</string>
        </array>
    </dict>
</array>
```

## Testing Firebase Integration

After completing the setup, you can test the Firebase integration by running:

```dart
// Add this code temporarily to your app to verify Firebase is working
import 'package:firebase_core/firebase_core.dart';

void testFirebase() {
  print("Firebase initialized: ${Firebase.app().name}");
}
```

Call this function after Firebase initialization to verify it's working correctly.
