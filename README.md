# WAZEET Flutter App

A mobile application built with Flutter for the WAZEET platform.

## Project Structure

- `android/` - Android-specific configurations and native code
- `ios/` - iOS-specific configurations and native code  
- `lib/` - Main Dart source code
- `test/` - Unit and widget tests
- `pubspec.yaml` - Flutter project configuration and dependencies

## Firebase Integration

This project is integrated with Firebase and includes:

- **Firebase Core** - Essential Firebase functionality
- **Firebase Auth** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage

### Firebase Configuration Files
- `android/app/google-services.json` - Android Firebase configuration
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase configuration

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Android Studio or Xcode for device emulation
- VS Code with Flutter and Dart extensions (recommended)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

#### Debug Mode
```bash
flutter run
```

#### Release Mode
```bash
flutter run --release
```

### Testing

Run unit and widget tests:
```bash
flutter test
```

### Building

#### Android APK
```bash
flutter build apk
```

#### iOS (requires macOS and Xcode)
```bash
flutter build ios
```

## Development Guidelines

- Follow Flutter best practices and Material Design guidelines
- Use proper state management patterns
- Write tests for critical functionality
- Keep code modular and well-documented

## VS Code Configuration

The project includes:
- Launch configurations for debugging in different modes
- Tasks for running Flutter commands
- Recommended settings for Flutter development

Press `F5` or use the Run and Debug panel to start debugging the app.
