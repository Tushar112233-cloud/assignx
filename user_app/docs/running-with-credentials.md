# Running Flutter App with Credentials

**Last Updated:** 2026-01-02

---

## Quick Start

### ⚡ Simplest Way (Default Credentials)

The app already has credentials built-in as defaults:

```bash
cd user_app
flutter run
```

### 🎯 Using Run Scripts (Recommended)

**Windows:**
```bash
cd user_app
scripts\run_with_credentials.bat
```

**Mac/Linux:**
```bash
cd user_app
chmod +x scripts/run_with_credentials.sh
./scripts/run_with_credentials.sh
```

**With specific device:**
```bash
# Windows
scripts\run_with_credentials.bat emulator-5554

# Mac/Linux
./scripts/run_with_credentials.sh emulator-5554
```

---

## 📱 Available Devices

**List connected devices:**
```bash
flutter devices
```

**Run on specific device:**
```bash
# Android Emulator
flutter run -d emulator-5554

# Physical Android Device
flutter run -d <device-id>

# iOS Simulator (Mac only)
flutter run -d "iPhone 15 Pro"

# Chrome (Web)
flutter run -d chrome
```

---

## 🔑 Credentials Loaded

When you run with the scripts, these credentials are automatically loaded:

### Supabase
```
URL: https://eowrlcwcqrpavpfspcza.supabase.co
Anon Key: eyJhbGci...
```

### Google Sign-In
```
Web Client ID: 224490208184-iiri7u0nnu17r26b5vsh1ksc0otnm73c.apps.googleusercontent.com
```

### Razorpay (Test Mode)
```
Key ID: rzp_test_Rv45IObrwfKRyf
Key Secret: p2ZIwNBpnf1Gh7icvCm6oicD
Test Mode: true
```

---

## 🏗️ Build Commands

### Development Build
```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://eowrlcwcqrpavpfspcza.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<key> \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<client-id> \
  --dart-define=RAZORPAY_KEY_ID=rzp_test_Rv45IObrwfKRyf \
  --dart-define=RAZORPAY_KEY_SECRET=p2ZIwNBpnf1Gh7icvCm6oicD
```

### Release Build
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://eowrlcwcqrpavpfspcza.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<key> \
  --dart-define=GOOGLE_WEB_CLIENT_ID=<client-id> \
  --dart-define=RAZORPAY_KEY_ID=rzp_live_XXXXXXXXXX \
  --dart-define=RAZORPAY_KEY_SECRET=<live-secret> \
  --dart-define=RAZORPAY_TEST_MODE=false
```

---

## 🧪 Testing Razorpay

Once the app is running, you can test payments:

### Test Cards
```
Success: 4111 1111 1111 1111
Failure: 4000 0000 0000 0002
CVV: Any 3 digits
Expiry: Any future date
```

### Test UPI
```
Success: success@razorpay
Failure: failure@razorpay
```

---

## 🐛 Troubleshooting

### "Error: dart-define not found"
Make sure you're using Flutter 2.0+:
```bash
flutter --version
flutter upgrade
```

### "Gradle build failed"
Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

### "Google Sign-In not working"
1. Check `google-services.json` is in `android/app/`
2. Verify SHA-1 fingerprint is added to Firebase
3. Run: `./gradlew signingReport` to get SHA-1

### "Razorpay checkout not opening"
1. Verify Razorpay SDK is in `pubspec.yaml`
2. Check API key is correct
3. Ensure test mode is enabled

---

## 📁 Configuration Files

- [razorpay_config.dart](../lib/core/config/razorpay_config.dart) - Razorpay settings
- [supabase_config.dart](../lib/core/config/supabase_config.dart) - Supabase settings
- [google-services.json](../android/app/google-services.json) - Google/Firebase config
- [pubspec.yaml](../pubspec.yaml) - Dependencies

---

## ✅ Verification Checklist

After running the app:

- [ ] App starts without errors
- [ ] Can see login screen
- [ ] Google Sign-In button visible
- [ ] Can navigate through app
- [ ] Payment features accessible
- [ ] Test payment works with test cards

---

## 🔗 Related Documentation

- [Razorpay Setup](../../user-web/docs/razorpay-setup.md)
- [Google Sign-In Guide](./google-signin-setup.md) (if exists)
- [Supabase Configuration](./supabase-setup.md) (if exists)

---

**For Web App:** See [user-web README](../../user-web/README.md)
