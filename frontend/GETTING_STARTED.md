# Getting Started with SENTRIX

Quick start guide for setting up and running the SENTRIX Flutter application.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher (comes with Flutter)
- **Android Studio** or **Xcode** (for emulator/simulator)
- **Git**: For version control
- **VS Code** or **Android Studio IDE**

### Check Your Setup

```bash
flutter doctor
```

This command will verify your Flutter installation and show any missing dependencies.

## Installation Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd flutter
```

### 2. Get Dependencies

```bash
flutter pub get
```

This installs all packages defined in `pubspec.yaml`.

### 3. Generate Code (if needed)

If the project uses build_runner:

```bash
flutter pub run build_runner build
```

### 4. Run the App

On an emulator/simulator:

```bash
flutter run
```

On a physical device (connected via USB):

```bash
flutter run -d <device-id>
```

List available devices:

```bash
flutter devices
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core configuration
│   ├── config/              # App configuration
│   ├── constants/           # Constants (colors, strings, enums)
│   ├── routes/              # Routing
│   ├── services/            # Service locator
│   └── theme/               # Theming
├── features/                # Feature modules
│   ├── auth/                # Authentication
│   ├── home/                # Home screen
│   ├── chat/                # Messaging
│   ├── groups/              # Group management
│   ├── qr/                  # QR features
│   ├── admin/               # Admin features
│   ├── settings/            # Settings
│   ├── error/               # Error handling
│   ├── dependent/           # Dependent UI
│   └── notifications/       # Notifications
├── models/                  # Data models
├── services/                # Backend services
├── shared/                  # Shared widgets and layouts
└── utils/                   # Utilities and helpers
```

## Test Accounts

Use these credentials to test the app:

### Admin Account
- **Email**: admin@sentrix.com
- **Password**: Password123

### Personnel Account
- **Email**: personnel@sentrix.com
- **Password**: Password123

### Dependent Account
- **Email**: dependent@sentrix.com
- **Password**: Password123

## Common Commands

### Development
```bash
# Run with verbose output
flutter run -v

# Run specific file
flutter run lib/main.dart

# Run with profile mode
flutter run --profile

# Hot reload (with app running in another terminal)
r
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Fix formatting issues
dart format --fix lib/
```

### Building
```bash
# Build APK
flutter build apk

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios

# Build release iOS
flutter build ios --release

# Clean build
flutter clean
```

### Testing
```bash
# Run tests
flutter test

# Run tests with coverage
dart pub global activate coverage
dart pub global run coverage:test_with_coverage
```

## Debugging Tips

### Enable Debug Logging

In `main.dart`, the app uses `LogService` for logging. To view logs:

```bash
flutter logs
```

### Use DevTools

```bash
flutter pub global activate devtools
devtools
```

Then open the browser to the provided URL and connect your running app.

### Check App State

Use the Provider DevTools extension for VS Code to inspect state changes.

## Troubleshooting

### Build Issues

```bash
# Clear build artifacts
flutter clean

# Clear cache
flutter pub cache clean

# Reinstall dependencies
flutter pub get

# Try again
flutter run
```

### Dependency Conflicts

```bash
# Get latest compatible versions
flutter pub upgrade

# Resolve conflicts
flutter pub get
```

### Android Gradle Issues

```bash
cd android
./gradlew clean
cd ..
flutter run
```

### iOS Issues

```bash
cd ios
rm -rf Pods
rm Podfile.lock
cd ..
flutter pub get
flutter run
```

## IDE Setup

### VS Code

1. Install Flutter extension by Google
2. Install Dart extension by Dart Code
3. Open workspace
4. VS Code will prompt to get dependencies

### Android Studio

1. Install Flutter plugin
2. Install Dart plugin
3. Open project as Flutter project
4. Let IDE download dependencies

## Hot Reload

When running with `flutter run`, you can:

- Press `r` for hot reload (preserves app state)
- Press `R` for hot restart (full restart)
- Press `q` to quit the app

## What's Next?

1. **Explore the code**: Start with `lib/main.dart` and follow the feature structure
2. **Review the design system**: Check `lib/core/theme/app_theme.dart`
3. **Understanding authentication**: See `lib/features/auth/`
4. **Check API integration**: See `lib/services/api_service.dart`

## Key Features to Explore

1. **Authentication Flow**: `lib/features/auth/`
   - Splash screen
   - Login
   - Face authentication
   - Device verification

2. **Chat System**: `lib/features/chat/`
   - Real-time messaging
   - Message history
   - Typing indicators

3. **Groups**: `lib/features/groups/`
   - Create and manage groups
   - Group chat
   - Member management

4. **QR Module**: `lib/features/qr/`
   - QR generation
   - QR scanning
   - Validation and history

5. **Admin Features**: `lib/features/admin/`
   - User management
   - Approvals
   - Statistics

## Documentation

- **Project Structure**: See `PROJECT_STRUCTURE.md`
- **API Documentation**: See `lib/services/api_service.dart`
- **Design System**: See `lib/core/theme/`
- **Changelog**: See `CHANGELOG.md`

## Support & Resources

### Flutter Resources
- [Flutter Official Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Samples](https://github.com/flutter/samples)

### Provider Package
- [Provider Documentation](https://pub.dev/packages/provider)
- [Flutter State Management Guide](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)

## Next Steps

Once you have the app running:

1. Explore the UI with test accounts
2. Review the codebase structure
3. Understand the state management pattern
4. Check the API integration points
5. Plan your customizations

## Performance Tips

- Use `const` constructors where possible
- Avoid rebuilding unnecessary widgets
- Use Provider selectors for fine-grained updates
- Monitor with DevTools Performance tab

## Building Your Own Features

To add a new feature:

1. Create a new folder under `lib/features/`
2. Create standard subdirectories: `controllers/`, `models/`, `screens/`, `widgets/`
3. Create a controller extending `ChangeNotifier`
4. Implement screens and widgets
5. Register the controller in `main.dart` as a Provider
6. Update routing in `lib/core/routes/app_routes.dart`

---

**Need Help?**
- Check the documentation in each directory
- Review similar features for patterns
- Check the design system in `lib/core/theme/`
- Consult the main README.md for overview

**Happy Coding! 🚀**
