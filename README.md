# Fixora

Fixora is a Flutter app for finding local home service professionals and booking services.

## Features

- User signup and login
- Onboarding screen
- Find service professionals
- Search providers
- Provider categories
- Provider details
- Create and manage bookings
- Customer and provider modes
- Booking status updates
- Profile editing
- Profile image selection
- Password update
- Light and dark mode
- Local data storage with Hive
- Provider state management with Provider

## Requirements

- Flutter
- Dart
- Android Studio or Xcode
- An Android emulator, iOS simulator, or physical device

## Run the project

Clone the repository:

```bash
git clone https://github.com/ruvindu-dulaksha/fixora.git
cd fixora
```

Install the packages:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

## Run tests

```bash
flutter test
```

## Check the code

```bash
flutter analyze
```

## Main folders

```text
lib/
  data/       Provider data and repository
  models/     App data models
  screen/     App screens
  state/      Provider state management
  theme/      Light and dark themes
  utils/      Booking rules

assets/
  data/       Provider JSON data
  images/     App images
  animations/ Onboarding animation

test/         Unit tests
```

## Local storage

The app uses Hive to store local user data, settings, profile information, and bookings.

This is a local demo application. Authentication data is stored locally on the device.
