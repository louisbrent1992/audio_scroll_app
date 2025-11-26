# AudioScroll

A short-form audio discovery platform for audiobooks. Discover your next favorite audiobook through engaging 30-90 second snippets in a vertical swipe feed.

## Features

- **Vertical Swipe Feed**: Swipe up/down to navigate through audiobook snippets
- **Karaoke-Style Captions**: Words highlight in sync with narration
- **Interactive Player**: Tap to play/pause, double-tap to like, long-press for speed controls
- **Onboarding Quiz**: Personalize your experience with genre and narrator preferences
- **Library Management**: Organize books into Wishlist, History, and Purchased sections
- **Search & Explore**: Search by mood, narrator, or genre
- **Unified Theme**: Consistent design system with responsive layouts

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android Studio / Xcode for mobile development

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models
│   └── audiobook_snippet.dart
├── screens/                  # Screen widgets
│   ├── feed_screen.dart
│   ├── onboarding_screen.dart
│   ├── library_screen.dart
│   └── search_screen.dart
├── widgets/                  # Reusable widgets
│   ├── audio_feed_card.dart
│   └── karaoke_captions.dart
├── services/                 # Business logic
│   ├── audio_player_service.dart
│   └── mock_data_service.dart
└── theme/                    # Theme configuration
    └── app_theme.dart
```

## Key Dependencies

- `just_audio`: Audio playback
- `cached_network_image`: Image caching
- `google_fonts`: Custom typography
- `flutter_animate`: Animations
- `share_plus`: Social sharing
- `url_launcher`: Deep linking to purchase pages
