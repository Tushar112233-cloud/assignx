# Magic Link (Passwordless) Authentication Setup

This document describes the native configuration required for magic link authentication with deep link handling.

## Overview

Magic link authentication allows users to sign in without a password by receiving an email with a special link. When the user clicks the link, the app opens and automatically signs them in.

## Deep Link Configuration

The app uses the following deep link scheme:
- **Scheme**: `assignx`
- **Host**: `auth-callback`
- **Full URL Pattern**: `assignx://auth-callback`

## Android Configuration

Add the following intent filter to your `AndroidManifest.xml` inside the main `<activity>` tag:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity
    android:name=".MainActivity"
    ...>

    <!-- Existing intent filters... -->

    <!-- Deep link handler for magic link authentication -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="assignx"
            android:host="auth-callback" />
    </intent-filter>
</activity>
```

### Full AndroidManifest.xml Example

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="AssignX"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- Main launcher intent -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- Deep link handler for magic link authentication -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="assignx"
                    android:host="auth-callback" />
            </intent-filter>

            <!-- Specifies an Android theme for Activity subclasses -->
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
        </activity>

        <!-- Don't delete the meta-data below. -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## iOS Configuration

Add the following to your `Info.plist`:

```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <!-- Existing keys... -->

    <!-- URL Types for deep link handling -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.assignx.app</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>assignx</string>
            </array>
        </dict>
    </array>

    <!-- Associated Domains for Universal Links (optional, for HTTPS links) -->
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:assignx.app</string>
    </array>
</dict>
```

### Full Info.plist Section

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... other entries ... -->

    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.assignx.app</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>assignx</string>
            </array>
        </dict>
    </array>

    <!-- ... other entries ... -->
</dict>
</plist>
```

## Supabase Configuration

In your Supabase dashboard, configure the redirect URL:

1. Go to **Authentication** > **URL Configuration**
2. Add `assignx://auth-callback` to the **Redirect URLs** list

## Flutter Deep Link Handling

The app uses `go_router` for handling deep links. The auth callback route is defined in `app_router.dart`:

```dart
GoRoute(
  path: RouteNames.authCallback,
  name: 'authCallback',
  redirect: (context, state) {
    // The Supabase auth listener handles the session
    return RouteNames.home;
  },
),
```

The Supabase SDK automatically handles the deep link tokens and updates the auth state. The `AuthStateNotifier` listens for auth state changes and updates the app accordingly.

## Testing Deep Links

### Android (ADB)

```bash
# Test the deep link
adb shell am start -W -a android.intent.action.VIEW -d "assignx://auth-callback" com.assignx.app

# With parameters (simulating actual magic link)
adb shell am start -W -a android.intent.action.VIEW -d "assignx://auth-callback?access_token=test&refresh_token=test" com.assignx.app
```

### iOS (xcrun)

```bash
# Test the deep link
xcrun simctl openurl booted "assignx://auth-callback"

# With parameters
xcrun simctl openurl booted "assignx://auth-callback?access_token=test&refresh_token=test"
```

## Flow Diagram

```
1. User enters email on login/signup screen
2. App calls Supabase signInWithOtp(email, redirectTo: 'assignx://auth-callback')
3. Supabase sends magic link email
4. User clicks link in email
5. Link opens app via deep link scheme (assignx://auth-callback?tokens...)
6. Supabase SDK parses tokens and creates session
7. Auth state listener detects sign-in
8. App navigates to home screen
```

## Troubleshooting

### Link doesn't open the app

1. Verify the scheme is correctly registered in AndroidManifest.xml/Info.plist
2. Check that the redirect URL is added to Supabase dashboard
3. Ensure the app is installed on the device/emulator
4. On Android, try clearing defaults for the browser app

### Session not created after clicking link

1. Check that the link hasn't expired (default: 10 minutes)
2. Verify the tokens are being passed correctly in the URL
3. Check Supabase auth logs for errors
4. Ensure the app is listening for auth state changes

### Magic link not received

1. Check spam/junk folder
2. Verify email address is correct
3. Check Supabase email sending limits
4. Verify SMTP settings in Supabase dashboard
