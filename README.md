# Flutter quickstart

## Features

- State Management: Redux ✅
- Dio encapsulation (or wrapping) ✅
  - Error handling
  - Logging
  - Request cancellation
  - Dynamic Headers
  - Response data processing
  - File upload and download
  - Persistent Cookies
  - Token refresh
  - Request queue and concurrency control
- Fluro for route management ✅

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.2
  dio: ^5.3.1
  logger: ^2.0.1
  cookie_jar: ^4.0.8
  dio_cookie_manager: ^3.1.0
  path_provider: ^2.0.15
  fluro: ^2.0.5
  redux: ^5.0.0
  flutter_redux: ^0.10.0
  intl: ^0.18.1
  flutter_screenutil: ^5.8.4
  shared_preferences: ^2.2.0
  crypto: ^3.0.3
  device_info_plus: ^9.0.2
  package_info_plus: ^4.0.2
```

## Getting Started

```bash
# install package
flutter pub get
# run
flutter run
# build
flutter build [platform]  # e.g., flutter build ios or flutter build apk
```
