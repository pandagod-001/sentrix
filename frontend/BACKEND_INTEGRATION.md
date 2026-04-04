# VRYA Backend-Frontend Integration Guide

## ✅ What's Connected

### 1. **Configuration Layer** (`lib/core/config/app_config.dart`)
- Centralized API configuration
- All backend endpoints defined
- Easy to switch between development/staging/production

### 2. **API Service** (`lib/services/api_service.dart`)
- Real HTTP requests (was using mocks)
- Automatic token/auth header management
- Error handling and timeouts
- Complete endpoint support:
  - Authentication (login, register, logout)
  - Users (get, update, profile)
  - Chats & Messages
  - Groups
  - QR Codes
  - Face Authentication
  - Admin operations

### 3. **Auth Service** (`lib/services/auth_service.dart`)
- Real API calls for login/register
- Token management
- Error messaging
- Session validation

## 🔧 Configuration for Local Development

### Android Emulator
```dart
// In app_config.dart, change:
static const String apiBaseUrl = 'http://10.0.2.2:8000'; // Maps localhost for Android emulator
```

### iOS Simulator
```dart
// In app_config.dart, change:
static const String apiBaseUrl = 'http://localhost:8000';
```

### Physical Device
```dart
// In app_config.dart, change:
static const String apiBaseUrl = 'http://192.168.x.x:8000'; // Your machine's local IP
```

### Production
```dart
// In app_config.dart, change:
static const String apiBaseUrl = 'https://api.vrya.com'; // Your production URL
```

## 🚀 Backend Requirements

Ensure your FastAPI backend has these endpoints:

### Auth Endpoints
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user, returns `access_token`
- `POST /api/auth/logout` - Logout user

### Response Format (Important!)
Login response must include:
```json
{
  "access_token": "jwt_token_here",
  "id": "user_id",
  "role": "personnel|admin|authority"
}
```

## 📝 Running the Backend Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Run the server
python -m uvicorn app.main:app --reload --port 8000
```

## ✅ Testing the Integration

1. **Start Backend**
   ```bash
  cd c:\Users\Shashank\OneDrive\Desktop\vrya
   pip install -r requirements.txt
   python -m uvicorn app.main:app --reload
   ```

2. **Update Config** (as shown above for your device)

3. **Run Flutter App**
   ```bash
   cd frontend/flutter
   flutter pub get
   flutter run
   ```

4. **Test Login** - Try logging in with a valid backend user

## 🐛 Troubleshooting

### Connection Refused
- Check backend is running (`http://localhost:8000`)
- Check API URL in `app_config.dart`
- For Android emulator, use `10.0.2.2` not `localhost`

### CORS Errors
- Backend already has CORS enabled in `main.py`
- Should allow all origins: `allow_origins=["*"]`

### Token Not Working
- Ensure backend returns `access_token` in login response
- Check token format matches what backend expects

### Invalid Endpoint
- Check backend endpoints match `app_config.dart` paths
- Backend endpoints should follow pattern `/api/{resource}`

## 📚 Next Steps

1. ✅ Test login/register with real backend
2. ⏳ Implement missing endpoints on backend as needed
3. ⏳ Add secure token storage (flutter_secure_storage)
4. ⏳ Implement WebSocket for real-time chat
5. ⏳ Add face authentication integration

## Files Modified
- ✅ `lib/core/config/app_config.dart` - Created
- ✅ `lib/services/api_service.dart` - Updated (removed mocks)
- ✅ `lib/services/auth_service.dart` - Updated (real API calls)
