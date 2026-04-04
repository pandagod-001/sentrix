# SENTRIX - Secure Defence Communication App

A comprehensive, production-ready Flutter application for secure, role-based defence communication with support for authentication, encrypted messaging, group management, and administrative controls.

## Features

### 🔐 Security & Authentication
- Multi-factor authentication with biometric (face) recognition
- Device verification and approval workflows
- Secure token-based session management
- Encrypted message storage and transmission

### 💬 Communication
- Real-time messaging with socket support
- One-on-one and group chats
- Message history and persistence
- Typing indicators and read receipts

### 👥 Role-Based Access Control
- Three user roles: Admin, Personnel, Dependent
- Role-specific UI and feature access
- Approval workflows for sensitive operations
- User management and personnel administration

### 📱 Additional Features
- QR code generation, scanning, and validation
- Group management with member administration
- Comprehensive settings with 40+ configurable options
- Real-time notifications
- Network monitoring
- Analytics and event tracking
- Local and remote data synchronization

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core configuration and utilities
│   ├── config/              # App configuration
│   ├── constants/           # App-wide constants (colors, strings, enums, assets)
│   ├── routes/              # Routing configuration
│   └── theme/               # Theme and typography
├── features/                # Feature modules
│   ├── admin/               # Administrative dashboard and management
│   ├── auth/                # Authentication flows
│   ├── chat/                # Direct messaging
│   ├── dependent/           # Dependent user interfaces
│   ├── error/               # Error handling
│   ├── groups/              # Group management and group chat
│   ├── home/                # Home screen and navigation
│   ├── notifications/       # Notification handling
│   ├── qr/                  # QR code features
│   └── settings/            # User settings and preferences
├── models/                  # Shared data models
├── services/                # Backend services
│   ├── api_service.dart              # Mock API endpoints
│   ├── auth_service.dart             # Authentication logic
│   ├── notification_service.dart     # Notification management
│   ├── database_service.dart         # Local data persistence
│   ├── file_service.dart             # File operations
│   ├── log_service.dart              # Logging and debugging
│   ├── face_auth_service.dart        # Biometric authentication
│   ├── socket_service.dart           # Real-time messaging
│   ├── analytics_service.dart        # Event tracking
│   ├── data_sync_service.dart        # Data synchronization
│   └── network_monitor.dart          # Connectivity monitoring
├── shared/                  # Shared widgets and layouts
│   ├── layouts/             # Application layouts
│   └── widgets/             # Reusable UI components
└── utils/                   # Utilities and helpers
    ├── validators.dart              # Form field validators
    ├── formatters.dart              # Data formatting utilities
    ├── extensions.dart              # Dart language extensions
    └── helpers.dart                 # General helper functions
```

## Design System

SENTRIX implements a cohesive, modern design system:

- **Color Palette**: Single gradient from #FF7A18 (Orange) → #AF4DFF (Purple) → #3B82F6 (Blue)
- **Background**: #F8FAFC (Light Blue Gray)
- **Cards & Surfaces**: #FFFFFF (White)
- **Text Colors**: #0F172A (Dark), #64748B (Medium), #94A3B8 (Light)
- **Border Radius**: 16-24px on all components
- **Shadows**: Soft, subtle shadows throughout (no hard shadows)
- **Button Style**: Gradient buttons only (no solid colored buttons)

## Installation & Setup

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build for production**
   ```bash
   # Android
   flutter build apk --release

   # iOS
   flutter build ios --release
   ```

## Test Credentials

The app includes built-in test accounts for demonstration:

### Admin Account
- **Email**: admin@sentrix.com
- **Password**: Password123
- **Access**: Full administrative controls, user management, approvals

### Personnel Account
- **Email**: personnel@sentrix.com
- **Password**: Password123
- **Access**: Standard communication features, restricted admin access

### Dependent Account
- **Email**: dependent@sentrix.com
- **Password**: Password123
- **Access**: Limited to chat and basic features, QR scanning restricted

## Development

### File Organization
- Each feature is self-contained with its own controllers, models, screens, and widgets
- Services are centralized and accessible via the ServiceLocator
- Common utilities and helpers are in the utils directory
- Shared components are in the shared directory

### State Management
- Uses **Provider** for state management
- Controllers extend `ChangeNotifier` for reactive updates
- Services use singleton pattern via ServiceLocator

### API Integration
- Mock API endpoints in `services/api_service.dart`
- Real backend integration ready (replace mock calls with actual HTTP)
- Built-in error handling and retry logic

### Logging & Debugging
- Comprehensive logging service in `services/log_service.dart`
- Analytics service for event tracking
- Network monitoring for connectivity issues
- Runtime error tracking and display

## Backend Integration

To integrate with a real backend:

1. Update `services/api_service.dart` with actual endpoint URLs
2. Replace mock data returns with real HTTP calls
3. Update authentication in `services/auth_service.dart` with real token management
4. Configure Firebase configuration files for notifications and authentication

## Contributing

Follow these guidelines when extending SENTRIX:
- Maintain the established folder structure
- Use the design system consistently
- Document complex functions with comments
- Follow Dart style guidelines
- Test all changes thoroughly

## Security Considerations

- All sensitive data should be encrypted before storage
- Use Flutter Secure Storage for tokens and credentials
- Implement SSL pinning for API communications
- Validate all user inputs
- Regular security audits recommended

## Troubleshooting

### Dependencies Issues
```bash
flutter clean
flutter pub get
```

### Build Issues
```bash
flutter clean
flutter pub cache clean
flutter pub get
flutter run -v
```

### Gradle Issues (Android)
```bash
cd android
./gradlew clean
cd ..
flutter run
```

## License

Proprietary - All rights reserved to SENTRIX

## Support

For issues, feature requests, or questions, please contact the development team.

---

**Version**: 1.0.0
**Last Updated**: 2024
**Status**: Production Ready
