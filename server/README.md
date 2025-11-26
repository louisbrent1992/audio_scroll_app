# AudioScroll Backend API

Node.js backend with Firebase integration for managing dynamic app configuration, banners, and spotlight audiobooks.

## Features

- **Dynamic Theme Configuration**: Update app colors and UI settings without app rebuilds
- **Banner Management**: Create and manage promotional banners
- **Spotlight Audiobooks**: Feature specific audiobooks in the feed
- **Firebase Integration**: Uses Firestore for data storage
- **RESTful API**: Clean REST endpoints for all operations

## Setup

### Prerequisites

- Node.js 18+ 
- Firebase project with Firestore enabled
- Firebase service account credentials

### Installation

1. Install dependencies:
```bash
cd server
npm install
```

2. Set up environment variables:
```bash
cp .env.example .env
```

3. Edit `.env` with your Firebase credentials:
```env
PORT=3000
NODE_ENV=development
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@your-project-id.iam.gserviceaccount.com
CORS_ORIGIN=http://localhost:8080
```

### Getting Firebase Credentials

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Download the JSON file
6. Extract the values for `project_id`, `private_key`, and `client_email`

### Running the Server

Development mode (with auto-reload):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

The server will run on `http://localhost:3000` by default.

## API Endpoints

### App Configuration

- `GET /api/config` - Get current app configuration
- `PUT /api/config` - Update app configuration

### Banners

- `GET /api/banners` - Get all active banners
  - Query params: `platform` (ios/android/all), `targetAudience` (all/new_users/premium)
- `GET /api/banners/:id` - Get banner by ID
- `POST /api/banners` - Create a new banner
- `PUT /api/banners/:id` - Update a banner
- `DELETE /api/banners/:id` - Delete a banner

### Spotlight Audiobooks

- `GET /api/spotlight` - Get all active spotlight audiobooks
  - Query params: `platform` (ios/android/all), `targetAudience` (all/new_users/premium)
- `GET /api/spotlight/:id` - Get spotlight by ID
- `POST /api/spotlight` - Create a new spotlight
- `PUT /api/spotlight/:id` - Update a spotlight
- `DELETE /api/spotlight/:id` - Delete a spotlight

## Firestore Collections

The backend uses the following Firestore collections:

- `app_config` - App configuration (single document with id 'default')
- `banners` - Promotional banners
- `spotlight_audiobooks` - Featured audiobooks
- `audiobook_snippets` - Audiobook snippet data (referenced by spotlights)

## Example Usage

### Update Theme Colors

```bash
curl -X PUT http://localhost:3000/api/config \
  -H "Content-Type: application/json" \
  -d '{
    "theme": {
      "highlightColor": "#FF6B6B"
    }
  }'
```

### Create a Banner

```bash
curl -X POST http://localhost:3000/api/banners \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Summer Sale",
    "subtitle": "50% off all audiobooks",
    "imageUrl": "https://example.com/banner.jpg",
    "actionUrl": "https://example.com/sale",
    "actionText": "Shop Now",
    "priority": 10,
    "isActive": true,
    "platform": "all",
    "targetAudience": "all"
  }'
```

### Create a Spotlight

```bash
curl -X POST http://localhost:3000/api/spotlight \
  -H "Content-Type: application/json" \
  -d '{
    "audiobookSnippetId": "snippet-id-123",
    "title": "Featured Book",
    "promotionText": "Editor'\''s Pick",
    "badge": "New Release",
    "priority": 5,
    "isActive": true,
    "targetAudience": "all"
  }'
```

## Health Check

```bash
curl http://localhost:3000/health
```

## Development

The server uses ES modules. Make sure your `package.json` has `"type": "module"`.

## Production Deployment

For production, consider:

1. Using environment variables for sensitive data
2. Setting up proper CORS origins
3. Adding authentication/authorization
4. Setting up rate limiting
5. Using a process manager like PM2
6. Setting up logging and monitoring

