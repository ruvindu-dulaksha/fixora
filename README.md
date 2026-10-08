# Fixora

Fixora is a Flutter handyman service booking app. Customers can find local service providers, book services, and manage their bookings. Provider mode is included for managing jobs assigned to Kamal Perera.

## Main features

- Onboarding screen
- Local signup and login
- Provider search and category browsing
- Paginated provider list with infinite scrolling
- Loading, empty, error, retry, and refresh states
- Provider details and availability
- Booking form with validation
- Booking cost calculation
- Saturday surcharge
- Double-booking prevention
- Customer booking history
- Provider job management
- Customer and provider modes
- Profile editing and profile image
- Password update
- Light and dark themes
- Hive local storage
- Provider state management
- Unit tests

## Technology

- Flutter 3.44.2
- Dart 3.12.2
- Provider
- Hive
- Lottie
- Image Picker

## Requirements

- Flutter 3.44.2 or later
- Android Studio or Xcode
- Android emulator, iOS simulator, or a physical device

## Getting started

Clone the project:

```bash
git clone https://github.com/ruvindu-dulaksha/fixora.git
cd fixora
```

Install dependencies:

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

## Check the project

```bash
flutter analyze
```

## Project structure

```text
lib/
  data/       Repository and provider data loading
  models/     Booking and provider models
  screen/     Application screens
  state/      Provider and Hive application state
  theme/      Light and dark themes
  utils/      Booking rules and validation

assets/
  animations/ Onboarding animation
  data/       Provider JSON data
  images/     App logos and icons

test/         Unit tests
```

## Local data

The app uses Hive for local storage. It saves the local account, login state, theme preference, selected mode, profile image, and bookings on the device.

This project uses local demo authentication and does not connect to a backend.

## iOS photo access

The app can use the device photo library for selecting a profile image. On iOS, allow photo access when the permission prompt appears. If permission was previously denied, enable Photos access for Fixora in the device settings.
