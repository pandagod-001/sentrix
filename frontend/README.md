# VRYA Frontend

VRYA Frontend is the Flutter client for the VRYA secure communication platform. It provides the user interface for authentication, approval flows, direct chat, group chat, QR-based flows, and role-based navigation.

The app is built to work with the FastAPI backend in this repository. It supports mobile, desktop, and development builds, and it is designed to consume the backend API over a configurable base URL.

## What This App Does

The Flutter client provides:

- Login and device verification flows
- Face authentication screens
- Home dashboards for role-based navigation
- Direct chat and group chat interfaces
- User discovery and chat creation for approved users
- QR display and QR scanning flows
- Settings, profile, and support screens
- Real-time socket-driven conversation updates

## App Structure

```text
lib/
├── main.dart                     App entry point
├── core/                         Core configuration, routes, themes, and constants
├── features/                     Feature modules by domain
│   ├── admin/                    Admin dashboard and management screens
│   ├── auth/                     Login, face auth, device verification, splash
│   ├── chat/                     Direct chat list, chat screen, message widgets
│   ├── dependent/                Dependent home screen and restricted UI
│   ├── error/                    Not found and access denied screens
│   ├── groups/                   Group list, group detail, and group chat
│   ├── home/                     Home dashboard and role routing
│   ├── notifications/            Notification state and handling
│   ├── qr/                       QR display, scan, and result screens
│   └── settings/                 Profile and settings screens
├── models/                       Shared data models
├── services/                     API, auth, socket, storage, and utility services
├── shared/                       Shared layouts and reusable widgets
└── utils/                        Formatters, helpers, validators, and role helpers
```

## Key Features

### Authentication and Security

- Username and password login
- JWT session handling
- Device binding support
- Face verification support
- Approval-aware access control

### Messaging

- Direct messages between approved users
- Group messaging
- Chat history and previews
- Real-time socket updates
- User discovery for new chat creation

### Role-Based Experience

- Authority dashboard and approvals
- Personnel dashboard and chat access
- Dependent restrictions where applicable
- Screen routing based on the signed-in role

### Platform Features

- QR code generation and scanning
- Notifications
- Network monitoring
- Analytics hooks
- Local and remote data sync support

## Design System

The Flutter UI uses the shared VRYA design language:

- Dark text with high-contrast surfaces
- Gradient-driven accent styling
- Rounded cards and soft shadows
- Consistent spacing and typography
- Feature-specific dashboards rather than one generic layout

## Prerequisites

To run the frontend, install:

- Flutter SDK
- Dart SDK
- Android SDK for Android development
- A running VRYA backend

## Setup

From the `frontend` directory:

```bash
flutter pub get
```

If you are using VS Code, select the Flutter device or emulator you want to run on before launching the app.

## Running the App

### Windows Desktop

```bash
flutter run -d windows --dart-define=SENTRIX_API_BASE_URL=http://127.0.0.1:8014
```

### Android Emulator

Use the emulator loopback address:

```bash
flutter run --dart-define=SENTRIX_API_BASE_URL=http://10.0.2.2:8014
```

### Physical Device or Local Network

If the backend is running on another machine in the same network, use that machine's LAN IP address:

```bash
flutter run --dart-define=SENTRIX_API_BASE_URL=http://192.168.1.104:8014
```

## Building

### Debug APK

```bash
flutter build apk --debug --dart-define=SENTRIX_API_BASE_URL=http://192.168.1.104:8014
```

### Release APK

```bash
flutter build apk --release --dart-define=SENTRIX_API_BASE_URL=https://api.yourdomain.com
```

### Windows Release Build

```bash
flutter build windows --release --dart-define=SENTRIX_API_BASE_URL=https://api.yourdomain.com
```

### Web Release Build

```bash
flutter build web --release --dart-define=SENTRIX_API_BASE_URL=https://api.yourdomain.com
```

## Backend Integration

The frontend expects the backend API to be available at the configured base URL.

Important integration points:

- Authentication requests
- Approved user listing
- Chat creation and message sending
- Group retrieval and creation
- QR and face verification endpoints

If you change backend routes or response shapes, update `lib/services/api_service.dart` and the related feature controllers.

## Deployment

### Local Network Deployment

This mode is useful for testing on multiple devices inside the same LAN.

1. Start the backend on a server machine.
2. Bind the backend to `0.0.0.0`.
3. Use the server's LAN IP address as the configured backend base URL.
4. Make sure the backend port is reachable from the client device.
5. Install the APK or run the Flutter app on the target device.

Example:

```bash
flutter build apk --release --dart-define=SENTRIX_API_BASE_URL=http://192.168.1.104:8014
```

### Production Deployment

For production, build the app against the hosted backend URL and distribute the compiled app through your normal release process.

Recommended steps:

1. Host the backend on a server with HTTPS enabled.
2. Use a stable API domain such as `https://api.yourdomain.com`.
3. Build the Flutter app with the production API URL.
4. Distribute the APK, desktop build, or web build to your users.
5. Keep backend and frontend CORS settings aligned if you are using the web build.

Example production build:

```bash
flutter build apk --release --dart-define=SENTRIX_API_BASE_URL=https://api.yourdomain.com
```

## Development Notes

### State Management

- Provider is used for app-wide and feature-specific state
- Controllers extend `ChangeNotifier`
- Feature logic stays in controllers and services rather than widgets

### Service Layer

- `api_service.dart` handles backend communication
- `auth_service.dart` manages authentication-related logic
- `socket_service.dart` manages live chat connections
- `database_service.dart` supports local persistence where needed

### User Discovery

Approved users are loaded into the chat UI so personnel can start direct conversations without manual API usage.

## Troubleshooting

### App does not connect to the backend

- Confirm the backend is running.
- Check the configured backend base URL value.
- Use `10.0.2.2` for Android emulator access to a local backend.

### UI changes do not appear

- Restart the app instead of relying on hot reload for large navigation or service changes.
- Run a fresh build if you changed API constants or route logic.

### Users are not listed in chat discovery

- Make sure the backend `/api/users` endpoint is returning approved users.
- Confirm the logged-in user is approved.
- Check the Flutter console for API errors.

### Build problems

```bash
flutter clean
flutter pub get
flutter run -v
```

For Android-specific issues:

```bash
cd android
./gradlew clean
cd ..
flutter run
```

## Testing

Run Flutter analyzer checks from the `frontend` folder:

```bash
flutter analyze
```

If you want a more complete validation, run the backend test suite from the repository root as well.

## Contributing

When extending the Flutter app:

- Keep feature code inside the matching feature folder
- Update the controller and service layer together when changing API behavior
- Preserve the role-based navigation flow
- Avoid committing generated build artifacts
- Test the target platform after UI or routing changes

## License

Proprietary. All rights reserved.
