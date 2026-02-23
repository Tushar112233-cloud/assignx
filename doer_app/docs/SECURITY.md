# DOER App - Security Guidelines

**Last Updated:** December 27, 2024
**Security Review Status:** Initial Assessment Complete
**Risk Level:** Medium (pre-production hardening required)

---

## Executive Summary

This document outlines security considerations, vulnerabilities, and recommendations for the DOER mobile application. The app handles sensitive user data including personal information, banking details, and financial transactions.

### Current Security Posture

| Area | Status | Risk |
|------|--------|------|
| Authentication | Good | Low |
| Data Storage | Needs Work | Medium |
| Input Validation | Needs Work | High |
| Network Security | Good | Low |
| Sensitive Data Handling | Needs Work | High |

---

## 1. Authentication & Authorization

### 1.1 Current Implementation

**Authentication Provider:** Supabase Auth

**Strengths:**
- Industry-standard JWT tokens
- Secure password hashing (bcrypt)
- Email verification support
- Session management handled by Supabase

**Configuration:**
```dart
// lib/core/services/supabase_service.dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

### 1.2 Recommendations

#### Add Session Timeout

```dart
// Implement session timeout check
class AuthNotifier extends Notifier<AuthState> {
  Timer? _sessionTimer;

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: 30), () {
      _showSessionExpiredDialog();
    });
  }

  void _resetSessionTimer() {
    _startSessionTimer();
  }
}
```

#### Add Biometric Authentication (Optional)

```yaml
# pubspec.yaml
dependencies:
  local_auth: ^2.2.0
```

```dart
// lib/core/services/biometric_service.dart
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access DOER',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

---

## 2. Data Storage Security

### 2.1 Current State

| Data Type | Storage | Encryption | Risk |
|-----------|---------|------------|------|
| Auth Tokens | Supabase SDK | Yes (managed) | Low |
| User Preferences | SharedPreferences | No | Medium |
| Cached Data | Memory | N/A | Low |
| Bank Details | Server Only | TLS in transit | Medium |

### 2.2 Recommendations

#### Use Secure Storage for Sensitive Data

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
// lib/core/services/secure_storage_service.dart
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
```

#### Data Classification

| Classification | Examples | Storage Requirement |
|----------------|----------|---------------------|
| Public | App version, feature flags | Any |
| Internal | User preferences, settings | Encrypted preferred |
| Confidential | Email, phone, profile | Encrypted required |
| Restricted | Bank details, passwords | Secure storage + encryption |

---

## 3. Input Validation

### 3.1 Current Vulnerabilities

**Risk Level:** HIGH

The application lacks comprehensive input validation, potentially allowing:
- SQL injection (if raw queries used)
- XSS attacks (if data displayed in WebView)
- Data corruption from malformed input
- Buffer overflow from excessively long inputs

### 3.2 Affected Screens

| Screen | Fields at Risk |
|--------|----------------|
| `edit_profile_screen.dart` | Name, Phone, Bio, Skills |
| `bank_details_screen.dart` | Account Number, IFSC, Bank Name |
| `register_screen.dart` | Email, Password, Name |
| `chat_screen.dart` | Message content |

### 3.3 Validation Implementation

#### Create Validation Utilities

```dart
// lib/shared/utils/validators.dart
class Validators {
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Name must be less than 100 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and periods';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Phone validation (Indian format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^(\+91)?[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Please enter a valid Indian phone number';
    }
    return null;
  }

  // Bank account validation
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    if (!RegExp(r'^\d{9,18}$').hasMatch(value)) {
      return 'Account number must be 9-18 digits';
    }
    return null;
  }

  // IFSC validation
  static String? validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'IFSC code is required';
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.toUpperCase())) {
      return 'Please enter a valid IFSC code';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  // Bio/text validation
  static String? validateBio(String? value, {int maxLength = 500}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length > maxLength) {
      return 'Maximum $maxLength characters allowed';
    }
    // Sanitize HTML/script tags
    if (RegExp(r'<[^>]*>').hasMatch(value)) {
      return 'HTML tags are not allowed';
    }
    return null;
  }
}
```

#### Apply to Forms

```dart
// In edit_profile_screen.dart
TextFormField(
  controller: _nameController,
  validator: Validators.validateName,
  maxLength: 100,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\-\.]')),
  ],
)
```

---

## 4. Sensitive Data Handling

### 4.1 Data Masking

#### Current Issue

Bank account numbers and phone numbers are displayed in full, creating privacy risks.

#### Implementation

```dart
// lib/shared/utils/masking_utils.dart
class MaskingUtils {
  /// Masks account number: 1234567890 -> ******7890
  static String maskAccountNumber(String number) {
    if (number.length <= 4) return number;
    final visible = number.substring(number.length - 4);
    return '${'*' * (number.length - 4)}$visible';
  }

  /// Masks phone: 9876543210 -> 98******10
  static String maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '${phone.substring(0, 2)}${'*' * (phone.length - 4)}${phone.substring(phone.length - 2)}';
  }

  /// Masks email: user@email.com -> u***@email.com
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    if (name.length <= 2) return email;
    return '${name[0]}${'*' * (name.length - 1)}@${parts[1]}';
  }

  /// Masks IFSC: HDFC0001234 -> HDFC****234
  static String maskIFSC(String ifsc) {
    if (ifsc.length != 11) return ifsc;
    return '${ifsc.substring(0, 4)}****${ifsc.substring(8)}';
  }
}
```

### 4.2 Secure Clipboard Handling

```dart
// Clear clipboard after copying sensitive data
void _copySensitiveData(String data) {
  Clipboard.setData(ClipboardData(text: data));

  // Auto-clear after 30 seconds
  Future.delayed(const Duration(seconds: 30), () {
    Clipboard.setData(const ClipboardData(text: ''));
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Copied - clipboard will be cleared in 30 seconds'),
    ),
  );
}
```

### 4.3 Screenshot Prevention (Optional)

```dart
// Prevent screenshots on sensitive screens
class SensitiveScreen extends StatefulWidget {
  @override
  State<SensitiveScreen> createState() => _SensitiveScreenState();
}

class _SensitiveScreenState extends State<SensitiveScreen> {
  @override
  void initState() {
    super.initState();
    // Android only - FLAG_SECURE
    if (Platform.isAndroid) {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
    super.dispose();
  }
}
```

---

## 5. Network Security

### 5.1 Current Implementation

**Strengths:**
- All API calls use HTTPS (enforced by Supabase)
- Authentication tokens sent via Authorization header
- TLS 1.2+ for all connections

### 5.2 Recommendations

#### Certificate Pinning

```yaml
# pubspec.yaml
dependencies:
  http_certificate_pinning: ^2.0.1
```

```dart
// lib/core/services/http_service.dart
class SecureHttpService {
  static const List<String> _allowedSHAFingerprints = [
    'SHA-256 fingerprint of your certificate',
  ];

  Future<Response> get(String url) async {
    final isSecure = await HttpCertificatePinning.check(
      serverURL: url,
      sha: SHA.SHA256,
      allowedSHAFingerprints: _allowedSHAFingerprints,
      timeout: 50,
    );

    if (!isSecure.secure) {
      throw SecurityException('Certificate pinning failed');
    }

    return http.get(Uri.parse(url));
  }
}
```

#### Request Timeout Configuration

```dart
// Configure timeouts for all requests
final client = http.Client();
final request = http.Request('GET', Uri.parse(url))
  ..headers['Connection'] = 'keep-alive';

final streamedResponse = await client.send(request).timeout(
  const Duration(seconds: 30),
  onTimeout: () {
    throw TimeoutException('Request timed out');
  },
);
```

---

## 6. Error Handling & Logging

### 6.1 Secure Error Messages

```dart
// DON'T: Expose internal details
catch (e) {
  showError('Database error: $e'); // Reveals stack trace
}

// DO: Show generic messages, log internally
catch (e, stackTrace) {
  LoggerService.error('Profile update failed', e, stackTrace);
  showError('Unable to update profile. Please try again.');
}
```

### 6.2 Logging Best Practices

```dart
// lib/core/services/logger_service.dart
class LoggerService {
  static bool _isProduction = const bool.fromEnvironment('dart.vm.product');

  static void error(String message, dynamic error, [StackTrace? stackTrace]) {
    if (_isProduction) {
      // Send to crash reporting (Crashlytics, Sentry)
      _sendToCrashReporting(message, error, stackTrace);
    } else {
      // Development logging
      debugPrint('ERROR: $message');
      debugPrint('Details: $error');
    }
  }

  // NEVER log sensitive data
  static void logUserAction(String action, {Map<String, dynamic>? params}) {
    // Sanitize params before logging
    final sanitized = _sanitizeParams(params);
    debugPrint('ACTION: $action - $sanitized');
  }

  static Map<String, dynamic>? _sanitizeParams(Map<String, dynamic>? params) {
    if (params == null) return null;

    final sensitiveKeys = ['password', 'account_number', 'ifsc', 'token'];
    return params.map((key, value) {
      if (sensitiveKeys.contains(key.toLowerCase())) {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });
  }
}
```

---

## 7. Security Checklist

### Pre-Launch Checklist

- [ ] **Authentication**
  - [ ] Session timeout implemented
  - [ ] Logout clears all local data
  - [ ] Failed login attempts limited
  - [ ] Password reset flow secure

- [ ] **Input Validation**
  - [ ] All forms have validators
  - [ ] Maximum input lengths enforced
  - [ ] Special characters sanitized
  - [ ] File uploads validated (future)

- [ ] **Data Protection**
  - [ ] Sensitive data masked in UI
  - [ ] Secure storage for tokens
  - [ ] Clipboard cleared after copy
  - [ ] No sensitive data in logs

- [ ] **Network Security**
  - [ ] HTTPS enforced
  - [ ] Certificate pinning (optional)
  - [ ] Request timeouts configured
  - [ ] API keys not in source code

- [ ] **Error Handling**
  - [ ] Generic error messages to users
  - [ ] Detailed logs for developers
  - [ ] Crash reporting configured
  - [ ] No stack traces in production

### Ongoing Security Tasks

| Task | Frequency | Owner |
|------|-----------|-------|
| Dependency vulnerability scan | Weekly | CI/CD |
| Code security review | Each PR | Reviewer |
| Penetration testing | Quarterly | Security Team |
| Security training | Annually | All Developers |

---

## 8. Incident Response

### 8.1 Security Incident Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| Critical | Active data breach | Immediate |
| High | Vulnerability discovered | 24 hours |
| Medium | Security misconfiguration | 1 week |
| Low | Best practice improvement | Next sprint |

### 8.2 Response Procedures

1. **Identify**: Detect and confirm the incident
2. **Contain**: Limit the impact (revoke tokens, disable features)
3. **Eradicate**: Remove the vulnerability
4. **Recover**: Restore normal operations
5. **Review**: Post-incident analysis and improvements

---

## 9. Compliance Considerations

### 9.1 Data Privacy

| Requirement | Status | Notes |
|-------------|--------|-------|
| User consent for data collection | Needed | Add consent screen |
| Data deletion capability | Needed | Implement account deletion |
| Data export capability | Needed | Implement data export |
| Privacy policy | Needed | Link in app settings |

### 9.2 Financial Data (if applicable)

- PCI DSS considerations for payment data
- Bank account handling best practices
- Transaction logging requirements

---

## Appendix

### A. Security Resources

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Supabase Security](https://supabase.com/docs/guides/platform/security)

### B. Related Documents

- [Architecture](./ARCHITECTURE.md)
- [Technical Debt](./TECHNICAL_DEBT.md)
- [API Security](./API_SECURITY.md) (future)

---

*This document should be reviewed and updated regularly as the application evolves.*
*Last security review: December 27, 2024*
