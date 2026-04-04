# VRYA

VRYA is a secure communication platform built around a FastAPI backend and a Flutter frontend. It is designed for controlled environments where user identity, device trust, and message access must be enforced centrally rather than only at login time.

The system combines authentication, biometric verification, device binding, approval workflows, and real-time chat. It also includes a local fallback database so the backend can keep working even when MongoDB is unavailable during development.

## What This Project Does

VRYA provides:

- Username and password authentication with JWT access tokens
- Device-based session binding
- Face verification support for high-risk actions
- Real-time direct messaging through WebSockets
- Group messaging and group management
- User approval flows for restricted accounts
- A Flutter client for mobile and desktop usage
- A local fallback database for offline or development mode

## System Overview

The security model is not based on a single login check. Instead, it evaluates whether a user is approved, whether the device is trusted, and whether the active session is still valid.

Typical flow:

1. User logs in with credentials.
2. Backend issues a JWT token.
3. The user is validated against device binding and approval state.
4. Face verification may be required depending on policy.
5. The user can then access chats, groups, and other permitted screens.
6. WebSocket messages are checked before delivery.

## Repository Structure

```text
vrya/
├── app/                     Backend application
│   ├── main.py              FastAPI entry point
│   ├── database.py          MongoDB plus local fallback storage
│   ├── dsie.py              Core security policy layer
│   ├── models.py            Backend data helpers
│   ├── routes/              API route handlers
│   ├── services/            Business logic and security services
│   └── utils/               Response and utility helpers
├── frontend/                Flutter application
│   ├── lib/                 UI, state management, services, models
│   ├── android/             Android build files
│   ├── windows/             Windows desktop build files
│   └── pubspec.yaml         Flutter dependencies
├── tests/                   Backend and integration tests
├── requirements.txt         Python dependencies
└── README.md                Project documentation
```

## Backend Architecture

The backend is built with FastAPI and organized around route modules and service modules.

### Main Backend Responsibilities

- Authenticate users
- Approve users and manage onboarding
- Return approved users for chat selection
- Create and fetch chats
- Send and receive messages
- Manage groups and dependent relationships
- Enforce security and access policy decisions

### Security Engine

The DSIE layer evaluates requests against the current security state. It can allow, block, or require reauthentication depending on policy and session state.

### Database Strategy

VRYA uses MongoDB when available. If MongoDB is not reachable during local development, the backend switches to a file-backed in-memory fallback store so data still survives process restarts.

This is useful for:

- Local development without Atlas connectivity
- Automated testing
- Demo environments
- Offline development workflows

## Frontend Architecture

The frontend is a Flutter application that consumes the FastAPI backend.

### Frontend Responsibilities

- Authentication screens and session handling
- Home dashboard by user role
- Direct chat list and chat screen
- Group list and group chat screens
- QR code and face-related flows
- Settings and profile views
- State management for remote data and chat updates

### Chat Experience

The app allows approved personnel to discover other approved personnel and start a direct chat from the UI. Direct chats are backed by the backend chat creation endpoint and WebSocket message delivery.

## Features

### Security and Identity

- JWT-based authentication
- Device verification
- Face verification support
- User approval workflow
- Risk-based security checks

### Messaging

- Direct messages between approved users
- Real-time WebSocket chat
- Chat history persistence
- Group messaging support
- Conversation list and message previews

### User Management

- Authority account approval flow
- Personnel and dependent account handling
- Approved-user listing for chat creation
- Role-aware dashboard navigation

### Platform Support

- Flutter mobile support
- Flutter desktop support
- Development-friendly fallback database

## Prerequisites

To run the full stack locally, install:

- Python 3.13 or compatible version used by the virtual environment
- Flutter SDK
- Android SDK if you plan to run on Android
- MongoDB if you want to use the remote database instead of fallback mode

## Backend Setup

From the repository root:

```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### Run the backend

```bash
$env:HOST='0.0.0.0'
$env:PORT='8014'
python -m app.main
```

If MongoDB is not available, the backend will start with the local fallback database automatically.

### Backend health check

```bash
curl http://127.0.0.1:8014/health
```

## Frontend Setup

From the `frontend` folder:

```bash
flutter pub get
```

### Run on Windows desktop

```bash
flutter run -d windows --dart-define=SENTRIX_API_BASE_URL=http://127.0.0.1:8014
```

### Run on Android emulator

Use the emulator loopback address when the app runs inside the emulator:

```bash
flutter run --dart-define=SENTRIX_API_BASE_URL=http://10.0.2.2:8014
```

### Build an APK

```bash
flutter build apk --debug --dart-define=SENTRIX_API_BASE_URL=http://192.168.1.104:8014
```

Adjust the IP address to match the machine running the backend on your network.

## Deployment

VRYA can be deployed in a local network for internal testing or in a production environment with a public backend and a hosted frontend.

### Local Network Deployment

Use this setup when the backend and frontend run on machines inside the same LAN.

1. Start the backend on the server machine.
2. Bind the backend to `0.0.0.0` so it listens on the network interface.
3. Use the server's LAN IP address in the Flutter API base URL setting.
4. Make sure the backend port is reachable from other devices on the network.
5. Install the APK or run the Flutter app on the target device.

Example backend command:

```bash
$env:HOST='0.0.0.0'
$env:PORT='8014'
python -m app.main
```

Example Flutter command for an Android device on the same network:

```bash
flutter run --dart-define=SENTRIX_API_BASE_URL=http://192.168.1.104:8014
```

For a packaged APK, build with the same backend URL:

```bash
flutter build apk --release --dart-define=SENTRIX_API_BASE_URL=http://192.168.1.104:8014
```

### Production Backend Deployment

For production, the backend should be hosted on a stable server with a public or private domain, proper TLS, and a managed MongoDB instance.

Recommended production steps:

1. Use a process manager such as systemd, Supervisor, or a Windows service to keep the backend running.
2. Put the FastAPI app behind a reverse proxy such as Nginx or Apache.
3. Serve the API over HTTPS.
4. Point `MONGODB_URI` to the production database.
5. Set strong secrets for JWT signing and any other runtime keys.
6. Restrict firewall rules to allow only the required ports.
7. Monitor application logs and database connectivity.

Example production start command:

```bash
python -m app.main
```

In production, `HOST` and `PORT` should be supplied by the hosting environment or service configuration.

### Production Frontend Deployment

The Flutter app can be deployed as a release APK, a desktop app, or a web build depending on your target platform.

Recommended approach:

1. Build the frontend against the production API base URL.
2. Distribute the APK through your internal app channel or device management tool.
3. For desktop, package the release build and point it to the production API.
4. For web, host the built files behind a static hosting provider and ensure the API allows the required CORS origins.

Example release build:

```bash
flutter build apk --release --dart-define=SENTRIX_API_BASE_URL=https://api.yourdomain.com
```

If you deploy the web frontend, update CORS settings in the backend to allow the production frontend origin.

## Running the Full Stack

Recommended local flow:

1. Start the backend on port 8014.
2. Confirm the health endpoint responds.
3. Start the Flutter app with the matching backend API base URL.
4. Log in with a test account.
5. Open the home screen or chat screen to view approved personnel.

## Testing

Run backend tests from the repository root:

```bash
python -m tests.run_all_tests
```

You can also run individual test modules when debugging a specific flow.

## Development Notes

### Local Persistence

When MongoDB is unavailable, VRYA falls back to a local serialized store. This keeps test data and demo conversations available across restarts.

### Chat Access Policy

Approved users can message other approved users. The backend enforces the rule, and the frontend now exposes approved personnel in the UI so chats can be started directly.

### User Discovery

The backend returns approved users for discovery and chat creation. The Flutter home screen and chat list use that data to let users start a new direct conversation without manual API calls.

## Troubleshooting

### Backend will not start

- Check whether another process is already using port 8014.
- If MongoDB is unavailable, confirm the fallback database log appears.
- Make sure the Python virtual environment is activated.

### Frontend shows old data

- Rebuild or restart the app after changing backend endpoints or UI code.
- Confirm the backend API base URL points to the machine where the backend is running.
- On Android emulator, use `http://10.0.2.2:8014`.

### Users do not appear in the UI

- Confirm the backend `/api/users` endpoint is returning approved users.
- Make sure the account used for login is approved.
- Verify the backend is running and reachable from the Flutter client.

### APK build is rejected by GitHub

- Do not commit large build artifacts such as APK files.
- Keep generated binaries out of version control.

## Contributing

When making changes:

- Keep backend route logic in the route modules and business rules in service modules.
- Preserve the existing role and approval model.
- Update both backend and frontend when changing data shapes.
- Run tests and analyzer checks before committing.
- Avoid committing generated build artifacts.

## License

Proprietary. All rights reserved.

## Summary

VRYA is a secure communication system for controlled environments. It is designed to keep identity, trust, and access decisions under backend control while still providing a usable chat experience through a Flutter client.
