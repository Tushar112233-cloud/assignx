# AssignX User App

A Flutter mobile application for the AssignX platform - connecting students and professionals with academic assignment help services.

## Overview

AssignX is a comprehensive platform that enables users to:
- Submit academic assignment requests
- Track project progress in real-time
- Communicate with assigned experts
- Manage wallet and payments
- Access a student marketplace

## Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** Riverpod 2.x
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Navigation:** go_router
- **Authentication:** Google OAuth (PKCE flow)

## Project Structure

```
lib/
├── core/                   # Core utilities and configuration
│   ├── config/            # App and Supabase configuration
│   ├── constants/         # Colors, spacing, text styles
│   ├── router/            # Navigation setup
│   └── utils/             # Helper functions
├── data/                   # Data layer
│   ├── models/            # Data models
│   └── repositories/      # Data access layer
├── features/              # Feature modules
│   ├── add_project/       # Project creation flows
│   ├── auth/              # Authentication screens
│   ├── home/              # Home screen and widgets
│   ├── marketplace/       # Student marketplace
│   ├── onboarding/        # User onboarding
│   ├── profile/           # User profile and settings
│   ├── projects/          # Project management
│   └── splash/            # App loading screen
├── providers/             # Riverpod providers
└── shared/                # Shared widgets and utilities
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Dart SDK 3.x or later
- Android Studio / VS Code with Flutter extensions
- A Supabase project

### Environment Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd user_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Supabase credentials:
```bash
# For development, pass credentials via dart-define:
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

4. (Optional) Configure additional settings:
```bash
flutter run \
  --dart-define=SUPPORT_PHONE=+911234567890 \
  --dart-define=SUPPORT_EMAIL=support@yourapp.com
```

### Running the App

```bash
# Development
flutter run

# Release build
flutter build apk --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

## Architecture

### Data Layer

The app follows a repository pattern for data access:

```
UI Layer (Widgets)
    |
Providers (Riverpod)
    |
Repositories
    |
Supabase Client
```

### State Management

We use Riverpod for state management with:
- `Provider` for simple dependencies
- `FutureProvider` for async data fetching
- `StateNotifierProvider` for complex state with mutations

### Navigation

Navigation is handled by go_router with:
- Declarative routing
- Deep linking support
- Auth-based redirects
- Named routes for type-safety

## Features

### Authentication
- Google Sign-In with PKCE flow
- Persistent sessions
- Automatic token refresh

### Project Management
- Create new projects with multiple service types
- Real-time status updates
- File upload and delivery
- Payment integration

### Wallet System
- In-app wallet balance
- Transaction history
- Multiple payment methods (UPI, Cards)
- Referral rewards

### Marketplace
- Buy/sell academic materials
- Housing listings
- Opportunity postings
- Community discussions

## Configuration

### App Configuration (`lib/core/config/app_config.dart`)

```dart
// Override via --dart-define at build time
static const String supportPhone = String.fromEnvironment(
  'SUPPORT_PHONE',
  defaultValue: '+919876543210',
);
```

### Supabase Configuration (`lib/core/config/supabase_config.dart`)

```dart
// Required at build time
static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Generate coverage report
flutter test --coverage
```

## Building for Production

### Android

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...

# Or for app bundle
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

### iOS

```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

## Code Quality

The project uses:
- `flutter_lints` for static analysis
- Consistent code formatting with `dart format`
- JSDoc-style comments for documentation

Run analysis:
```bash
flutter analyze
```

Format code:
```bash
dart format lib/
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and analysis
5. Submit a pull request

## License

This project is proprietary software. All rights reserved.

## Support

For support, contact support@assignx.in or use the in-app support feature.
