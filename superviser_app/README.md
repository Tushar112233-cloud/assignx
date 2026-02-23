# AdminX - Supervisor App

<p align="center">
  <img src="assets/icons/app_icon.png" alt="AdminX Logo" width="120" height="120">
</p>

<p align="center">
  <strong>Mobile supervisor dashboard for the AssignX academic assistance platform</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## Overview

AdminX is a Flutter mobile application for supervisors on the AssignX platform. Supervisors manage academic project requests, provide quotes, assign doers (writers), and ensure quality delivery.

### Key Capabilities

- **Request Management** - View and manage incoming project requests
- **Quoting System** - Analyze requests and submit price quotes
- **Doer Assignment** - Find and assign qualified doers to projects
- **Project Tracking** - Monitor project progress and deadlines
- **Real-time Chat** - Communicate with clients and doers
- **Earnings Dashboard** - Track commissions and payouts

---

## Features

| Feature | Description |
|---------|-------------|
| **Dashboard** | Overview of new requests and paid projects ready for assignment |
| **Smart Quoting** | Calculate quotes based on complexity, urgency, and subject |
| **Doer Matching** | Find available doers by expertise and ratings |
| **Project Timeline** | Visual status tracking from submission to completion |
| **In-App Chat** | Real-time messaging with clients and doers |
| **Earnings Analytics** | Charts and reports for earnings tracking |
| **Training Resources** | Video tutorials, guides, and pricing reference |
| **Support Center** | Create tickets and access FAQs |

---

## Screenshots

<p align="center">
  <i>Coming soon</i>
</p>

---

## Getting Started

### Prerequisites

- Flutter SDK 3.10.4 or higher
- Dart SDK 3.0+
- Android Studio / Xcode
- Supabase project (for backend)

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/your-org/superviser_app.git
cd superviser_app
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure environment variables**

Create a `.env` file or use dart-define:

```bash
# Option 1: dart-define (recommended for production)
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

4. **Run the app**

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

### Building for Production

```bash
# Android APK
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key

# Android App Bundle
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key

# iOS
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## Architecture

The app follows **Clean Architecture** with a feature-first folder structure.

```
lib/
├── core/                 # Shared core functionality
│   ├── config/           # Constants, environment
│   ├── network/          # Supabase client, exceptions
│   ├── router/           # GoRouter configuration
│   ├── theme/            # App theme and colors
│   ├── services/         # App-wide services
│   └── utils/            # Utility functions
│
├── features/             # Feature modules
│   ├── auth/             # Authentication
│   ├── dashboard/        # Main dashboard
│   ├── projects/         # Project management
│   ├── chat/             # Messaging
│   ├── profile/          # User profile
│   ├── earnings/         # Earnings tracking
│   └── ...               # Other features
│
└── shared/               # Shared widgets
    └── widgets/
```

### Technology Stack

| Layer | Technology |
|-------|------------|
| **UI Framework** | Flutter 3.10+ |
| **State Management** | Riverpod 2.x |
| **Navigation** | GoRouter 13.x |
| **Backend** | Supabase (PostgreSQL, Auth, Realtime) |
| **Local Storage** | SharedPreferences, SecureStorage |

### Data Flow

```
UI (Screens/Widgets)
        ↓ ref.watch()
Providers (StateNotifier)
        ↓ async calls
Repositories
        ↓ Supabase client
Database / API
```

---

## Documentation

Detailed documentation is available in the `/docs` folder:

| Document | Description |
|----------|-------------|
| [API Documentation](docs/api.md) | Repository methods and data models |
| [Components](docs/components.md) | Reusable UI widgets |
| [Screens](docs/screens.md) | All app screens and navigation |
| [Architecture](docs/architecture.md) | Technical architecture details |

---

## Development

### Code Style

The project follows Flutter's official style guide with these additions:

- Use `const` constructors wherever possible
- Add dartdoc comments to all public APIs
- Keep widgets small and focused
- Use Riverpod for all state management

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/features/auth/providers/auth_provider_test.dart
```

### Code Generation

Some features use code generation:

```bash
# Run build_runner for code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

---

## Environment Configuration

### Required Environment Variables

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public key |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBUG` | `false` | Enable debug logging |

---

## Project Structure Details

### Feature Module Structure

Each feature follows this pattern:

```
feature_name/
├── data/
│   ├── models/           # Data models with JSON serialization
│   └── repositories/     # Data access layer
├── domain/
│   └── entities/         # Business entities, enums
└── presentation/
    ├── providers/        # Riverpod state management
    ├── screens/          # Full-page widgets
    └── widgets/          # Feature-specific widgets
```

### Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, initialization |
| `lib/app.dart` | MaterialApp configuration |
| `lib/core/router/app_router.dart` | Route definitions and guards |
| `lib/core/network/supabase_client.dart` | Supabase initialization |
| `lib/core/theme/app_theme.dart` | Theme configuration |

---

## Dependencies

### Production Dependencies

```yaml
# State Management
flutter_riverpod: ^2.4.9

# Navigation
go_router: ^13.0.0

# Backend
supabase_flutter: ^2.3.0

# UI Components
flutter_svg: ^2.0.9
cached_network_image: ^3.3.0
shimmer: ^3.0.0
flutter_animate: ^4.3.0
fl_chart: ^1.1.1

# Forms
reactive_forms: ^16.1.1

# Utilities
intl: ^0.18.1
connectivity_plus: ^5.0.2
url_launcher: ^6.2.5
```

### Dev Dependencies

```yaml
flutter_test: sdk
flutter_lints: ^6.0.0
build_runner: ^2.4.8
riverpod_generator: ^2.3.9
json_serializable: ^6.7.1
freezed: ^2.4.6
```

---

## Deployment

### Android

1. Update `android/app/build.gradle` with your signing config
2. Build release APK/AAB
3. Upload to Google Play Console

### iOS

1. Configure signing in Xcode
2. Build iOS archive
3. Upload to App Store Connect

### CI/CD

GitHub Actions workflow is available at `.github/workflows/ci.yml` for:

- Running tests on PR
- Building release artifacts
- Code quality checks

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## License

This project is proprietary software. All rights reserved.

---

## Support

For support, email support@assignx.com or create a support ticket within the app.

---

<p align="center">
  Built with Flutter
</p>
