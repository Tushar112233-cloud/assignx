# DOER App

A Flutter mobile application for freelance academic writers ("Doers") to manage assignments, track earnings, and collaborate with supervisors.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.8.2-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.5.1-purple?style=for-the-badge)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)](LICENSE)

---

## Overview

DOER App is a comprehensive mobile platform designed for freelance academic writers to:

- **Browse and accept** writing assignments based on expertise
- **Track project progress** with real-time updates and status indicators
- **Manage deadlines** with countdown timers and push notifications
- **Submit work** with multi-file upload support
- **Handle revisions** with clear feedback tracking and communication
- **Track earnings** with detailed payment history
- **Access training resources** for continuous skill development
- **Use AI tools** for content checking and citation building

---

## Screenshots

> Screenshots coming soon. The app includes the following key screens:

### Authentication Flow
| Splash | Onboarding | Login | Register |
|:------:|:----------:|:-----:|:--------:|
| ![Splash](docs/screenshots/placeholder.png) | ![Onboarding](docs/screenshots/placeholder.png) | ![Login](docs/screenshots/placeholder.png) | ![Register](docs/screenshots/placeholder.png) |

### Activation Flow
| Training | Quiz | Bank Details | Activation Gate |
|:--------:|:----:|:------------:|:---------------:|
| ![Training](docs/screenshots/placeholder.png) | ![Quiz](docs/screenshots/placeholder.png) | ![Bank](docs/screenshots/placeholder.png) | ![Gate](docs/screenshots/placeholder.png) |

### Main App
| Dashboard | Project Detail | Workspace | Profile |
|:---------:|:--------------:|:---------:|:-------:|
| ![Dashboard](docs/screenshots/placeholder.png) | ![Project](docs/screenshots/placeholder.png) | ![Workspace](docs/screenshots/placeholder.png) | ![Profile](docs/screenshots/placeholder.png) |

### Resources
| Resources Hub | AI Checker | Citation Builder | Training Center |
|:-------------:|:----------:|:----------------:|:---------------:|
| ![Resources](docs/screenshots/placeholder.png) | ![AI](docs/screenshots/placeholder.png) | ![Citation](docs/screenshots/placeholder.png) | ![Training](docs/screenshots/placeholder.png) |

---

## Features

### Core Features

| Feature | Description |
|---------|-------------|
| **Dashboard** | Overview of assigned projects, deadlines, and earnings with real-time stats |
| **Project Workspace** | Full project management with requirements checklist and multi-file uploads |
| **Chat System** | Real-time communication with supervisors using Supabase Realtime |
| **Training Center** | Learning modules with video, PDF, and article content |
| **AI Checker** | Built-in tool to check content for AI-generated text |
| **Citation Builder** | Generate citations in APA, MLA, Chicago, Harvard, and IEEE formats |
| **Profile Management** | Personal info, bank details, skills, and settings management |
| **Payment Tracking** | Detailed earnings and transaction history |

### Authentication

- Email/password sign-up and sign-in
- Google OAuth integration
- OTP verification for phone numbers
- PKCE flow for enhanced security
- Secure session management with Supabase

### User Experience

- Material Design 3 theming
- Responsive layouts for all screen sizes
- Offline-capable architecture
- Push notifications support
- Pull-to-refresh on list screens
- Loading states and error handling

---

## Tech Stack

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Framework** | Flutter | 3.x | Cross-platform mobile development |
| **Language** | Dart | 3.x | Type-safe programming |
| **State Management** | Riverpod | 2.5.1 | Reactive state management |
| **Navigation** | go_router | 14.6.2 | Declarative routing |
| **Backend** | Supabase | 2.8.2 | Auth, Database, Storage, Realtime |
| **Local Storage** | flutter_secure_storage | - | Secure token storage |
| **Image Caching** | cached_network_image | - | Efficient image loading |
| **Forms** | flutter_form_builder | - | Form handling and validation |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── app.dart                   # MaterialApp configuration
│
├── core/                      # Core utilities and configuration
│   ├── config/                # Supabase and app configuration
│   │   └── supabase_config.dart
│   ├── constants/             # Colors, spacing, text styles, API
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   ├── app_text_styles.dart
│   │   └── api_constants.dart
│   ├── errors/                # Custom exceptions
│   │   └── exceptions.dart
│   ├── router/                # GoRouter navigation setup
│   ├── services/              # Device permissions, utilities
│   ├── theme/                 # App theming
│   └── utils/                 # Helpers, validators, extensions
│
├── data/                      # Data layer
│   ├── models/                # Data transfer objects
│   │   ├── models.dart        # Barrel file
│   │   ├── user_model.dart
│   │   ├── doer_model.dart
│   │   ├── project_model.dart
│   │   ├── activation_model.dart
│   │   └── ...
│   ├── repositories/          # Data access abstraction
│   │   ├── repositories.dart  # Barrel file
│   │   └── auth_repository.dart
│   └── mock/                  # Development mock data
│
├── features/                  # Feature modules (27 screens)
│   ├── splash/                # Splash screen
│   ├── onboarding/            # App introduction
│   │   ├── screens/
│   │   └── widgets/
│   ├── auth/                  # Login, registration, OTP
│   ├── activation/            # Doer activation flow
│   ├── dashboard/             # Main dashboard
│   ├── workspace/             # Project workspace
│   ├── resources/             # Training and tools
│   └── profile/               # User profile
│
├── providers/                 # Riverpod state providers
│   ├── auth_provider.dart
│   ├── activation_provider.dart
│   ├── dashboard_provider.dart
│   ├── workspace_provider.dart
│   └── ...
│
└── shared/                    # Shared components
    └── widgets/               # Reusable UI components
        ├── app_button.dart
        ├── app_text_field.dart
        ├── app_card.dart
        ├── app_avatar.dart
        ├── app_badge.dart
        └── ...
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart SDK 3.x (included with Flutter)
- Android Studio / VS Code with Flutter extensions
- Supabase account ([Create account](https://supabase.com))
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/doer_app.git
   cd doer_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**

   Create a Supabase project and configure environment variables:

   ```bash
   # Option 1: Using dart-define (recommended for development)
   flutter run \
     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your-anon-key \
     --dart-define=GOOGLE_WEB_CLIENT_ID=your-client-id
   ```

   ```bash
   # Option 2: Create a launch configuration in VS Code
   # .vscode/launch.json
   {
     "configurations": [
       {
         "name": "DOER App",
         "request": "launch",
         "type": "dart",
         "args": [
           "--dart-define=SUPABASE_URL=xxx",
           "--dart-define=SUPABASE_ANON_KEY=xxx"
         ]
       }
     ]
   }
   ```

4. **Run the app**
   ```bash
   # Development
   flutter run

   # Specific device
   flutter run -d <device_id>

   # List available devices
   flutter devices
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release \
  --dart-define=SUPABASE_URL=xxx \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --obfuscate \
  --split-debug-info=./debug-info

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=xxx \
  --dart-define=SUPABASE_ANON_KEY=xxx

# iOS
flutter build ios --release \
  --dart-define=SUPABASE_URL=xxx \
  --dart-define=SUPABASE_ANON_KEY=xxx
```

---

## Architecture

The app follows a **feature-first architecture** with **Riverpod** for state management:

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│     (Screens, Widgets - ConsumerWidget/StatefulWidget)       │
├─────────────────────────────────────────────────────────────┤
│                     Provider Layer                           │
│        (Riverpod Notifiers - Business Logic)                 │
├─────────────────────────────────────────────────────────────┤
│                   Repository Layer                           │
│            (Data Access Abstraction)                         │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
│      (Models, Supabase Client, Local Storage)                │
└─────────────────────────────────────────────────────────────┘
```

### State Management Pattern

```dart
// 1. Define state
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });
}

// 2. Create notifier
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    return const AuthState();
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signInWithPassword(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// 3. Use in widget
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return LoadingOverlay(
      isLoading: authState.status == AuthStatus.loading,
      child: LoginForm(
        onSubmit: (email, password) {
          ref.read(authProvider.notifier).signIn(email, password);
        },
      ),
    );
  }
}
```

---

## Key Features

### Activation Flow

New doers must complete a 3-step activation process:

1. **Training** - Complete required training modules (video, PDF, articles)
2. **Quiz** - Pass a knowledge assessment (minimum 70% score)
3. **Bank Details** - Submit bank account information for payments

### Project Lifecycle

```
Open → Assigned → In Progress → Submitted → Under Review → Completed/Revision → Paid
```

### File Management

- Multi-file upload with drag-and-drop
- Support for PDF, DOC, DOCX, ZIP formats
- Primary file designation
- File size limit: 25MB per file
- Automatic file type detection

---

## Documentation

Detailed documentation is available in the `/docs` folder:

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture and design patterns |
| [API.md](docs/API.md) | Data models and repository documentation |
| [COMPONENTS.md](docs/COMPONENTS.md) | Widget/component documentation |
| [SCREENS.md](docs/SCREENS.md) | Screen/page documentation |
| [SECURITY.md](docs/SECURITY.md) | Security guidelines and best practices |
| [TESTING.md](docs/TESTING.md) | Testing strategy and guidelines |
| [TECHNICAL_DEBT.md](docs/TECHNICAL_DEBT.md) | Technical debt register |

---

## Development

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use dartdoc comments for public APIs
- Prefer `const` constructors where possible
- Use meaningful variable and function names
- Maximum line length: 80 characters

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Linting

```bash
# Analyze code
flutter analyze

# Auto-fix issues
dart fix --apply
```

### Pre-commit Checklist

- [ ] All tests pass
- [ ] No analyzer warnings
- [ ] Code is formatted (`dart format .`)
- [ ] Documentation updated if needed
- [ ] No debug code or console logs

---

## Contributing

1. **Fork** the repository
2. **Create** a feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit** your changes
   ```bash
   git commit -m 'feat: Add amazing feature'
   ```
4. **Push** to the branch
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open** a Pull Request

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples:**
- `feat(auth): Add Google OAuth sign-in`
- `fix(dashboard): Fix project list not refreshing`
- `docs(readme): Update installation instructions`

---

## License

This project is proprietary software. All rights reserved.

---

## Support

For questions or issues:

- Create an issue in this repository
- Contact the development team
- Check the [documentation](docs/)

---

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Supabase](https://supabase.com) - Backend as a Service
- [Riverpod](https://riverpod.dev) - State management
- [go_router](https://pub.dev/packages/go_router) - Navigation

---

<p align="center">
  Built with Flutter and Supabase
</p>
