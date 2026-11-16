# 🎵 Flutter Music Player

A modern Android music player built with Flutter and Dart, designed to provide a smooth offline music listening experience with a clean architecture and a modern user interface.

## ✨ Features

- [x] Browse and play local audio files
- [x] Background audio playback
- [x] Play, pause, skip, and seek controls
- [x] Mini Player and Now Playing screen
- [x] Media notifications and lock screen controls
- [x] Shuffle and Repeat playback modes
- [x] Create, rename, and delete playlists
- [x] Add and remove tracks from playlists
- [x] Favorite tracks with persistent storage
- [x] Search the music library
- [x] Recently played history
- [x] Dark theme with neon purple UI

## 🚀 Planned Features

The following features are planned for future development:

- [ ] Lyrics support and synchronized lyrics
- [ ] Equalizer and audio effects
- [ ] Sleep timer
- [ ] Queue management (Up Next)
- [ ] Browse music by artists and albums
- [ ] Light theme
- [ ] Online music playback and streaming

## 🛠️ Tech Stack

- **Flutter** – UI framework
- **Dart** – Programming language
- **Riverpod** – State management
- **just_audio** – Audio playback
- **just_audio_background** – Background playback and media notifications
- **audio_session** – Audio session management
- **SharedPreferences** – Local data persistence
- **Media Browser** – Accessing local audio files

## 🏗️ Architecture

The project follows a **Feature-First + Clean Architecture** approach to ensure separation of concerns, maintainability, and scalability.

### Project Structure

```text
lib/
├── app/
│   ├── theme/
│   ├── app.dart
│   └── router.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── widgets/
│
└── features/
    ├── music/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    └── player/
        ├── data/
        ├── domain/
        └── presentation/
```

### Architecture Principles

- Clean Architecture
- Feature-First organization
- Separation of concerns
- Repository pattern
- Riverpod state management

## 📦 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android device or emulator

### Installation

1. Clone the repository:

```bash
git clone https://github.com/msharafice/flutter_music_player.git
```

2. Navigate to the project directory:

```bash
cd flutter_music_player
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## 📸 Screenshots

Screenshots and application previews will be added here.

## 🧪 Code Quality

To format and analyze the project, run:

```bash
dart format lib
flutter analyze
flutter test
```

## 📌 Project Status

**Status:** In Development 🚧

This project is actively being developed. New features, improvements, and documentation updates will be added over time.

## 👨‍💻 Author

**Mohammad Sharafi**

GitHub: [@msharafice](https://github.com/msharafice)

---

Made with Flutter and ❤️