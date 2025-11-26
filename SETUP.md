# AudioScroll Setup Guide

This guide will help you set up both the Flutter app and Node.js backend with Firebase integration.

## Architecture Overview

The app uses a **server-driven UI** approach where:
- **Theme/Colors**: Can be updated on the server without app rebuilds
- **Banners**: Promotional content managed via API
- **Spotlight Audiobooks**: Featured content managed via API
- **Feature Flags**: Enable/disable features remotely

## Backend Setup

### 1. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firestore Database
3. Go to Project Settings > Service Accounts
4. Generate a new private key (downloads JSON file)
5. Extract credentials from the JSON file

### 2. Backend Configuration

```bash
cd server
npm install
cp .env.example .env
```

Edit `.env` with your Firebase credentials:
```env
PORT=3000
NODE_ENV=development
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com
CORS_ORIGIN=http://localhost:8080
```

### 3. Start Backend Server

```bash
npm run dev  # Development mode with auto-reload
# or
npm start    # Production mode
```

Server runs on `http://localhost:3000`

## Flutter App Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure API Endpoint

Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
// For production: 'https://your-api-domain.com/api'
```

**Note**: For Android emulator, use `http://10.0.2.2:3000/api` instead of `localhost`

### 3. Run the App

```bash
flutter run
```

## Firestore Collections Structure

The backend automatically creates these collections:

### `app_config` (Single Document)
```json
{
  "id": "default",
  "version": 1,
  "theme": {
    "primaryColor": "#1A1A2E",
    "secondaryColor": "#16213E",
    "accentColor": "#0F3460",
    "highlightColor": "#E94560",
    "surfaceColor": "#0F0F1E",
    "backgroundColor": "#000000",
    "textPrimary": "#FFFFFF",
    "textSecondary": "#B0B0B0",
    "textTertiary": "#808080"
  },
  "features": {
    "enableBanners": true,
    "enableSpotlight": true,
    "enableOnboarding": true,
    "maxSnippetDuration": 90,
    "minSnippetDuration": 30
  }
}
```

### `banners` Collection
```json
{
  "title": "Summer Sale",
  "subtitle": "50% off all audiobooks",
  "imageUrl": "https://example.com/banner.jpg",
  "actionUrl": "https://example.com/sale",
  "actionText": "Shop Now",
  "priority": 10,
  "isActive": true,
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-12-31T23:59:59Z",
  "targetAudience": "all",
  "platform": "all"
}
```

### `spotlight_audiobooks` Collection
```json
{
  "audiobookSnippetId": "snippet-id-123",
  "title": "Featured Book",
  "priority": 5,
  "isActive": true,
  "promotionText": "Editor's Pick",
  "badge": "New Release",
  "targetAudience": "all"
}
```

## Testing the Setup

### 1. Test Backend Health

```bash
curl http://localhost:3000/health
```

### 2. Test Config Endpoint

```bash
curl http://localhost:3000/api/config
```

### 3. Update Theme (Example)

```bash
curl -X PUT http://localhost:3000/api/config \
  -H "Content-Type: application/json" \
  -d '{
    "theme": {
      "highlightColor": "#FF6B6B"
    }
  }'
```

Then restart the Flutter app to see the new color!

## How It Works

1. **App Launch**: Flutter app fetches config from server on startup
2. **Caching**: Config is cached locally for 1 hour
3. **Version Check**: App checks for config version updates in background
4. **Dynamic Updates**: Theme changes apply immediately on next app launch
5. **Banners/Spotlights**: Fetched on feed load, filtered by platform and audience

## Production Considerations

1. **API URL**: Update `ApiService.baseUrl` to production endpoint
2. **HTTPS**: Use HTTPS in production
3. **Authentication**: Add auth middleware to protect admin endpoints
4. **Rate Limiting**: Implement rate limiting for API endpoints
5. **Error Handling**: Add proper error logging and monitoring
6. **CORS**: Configure proper CORS origins for production

## Troubleshooting

### Backend won't start
- Check Firebase credentials in `.env`
- Ensure Firestore is enabled in Firebase Console
- Check Node.js version (requires 18+)

### Flutter app can't connect to backend
- Android emulator: Use `10.0.2.2` instead of `localhost`
- iOS simulator: Use `localhost` or your machine's IP
- Check CORS settings in backend
- Verify backend is running on correct port

### Theme not updating
- Check config version number increased
- Clear app cache/data
- Restart app completely
- Check network connectivity

## Next Steps

1. Set up Firebase Authentication for user management
2. Add admin dashboard for managing banners/spotlights
3. Implement analytics tracking
4. Add push notifications
5. Set up CI/CD pipeline

