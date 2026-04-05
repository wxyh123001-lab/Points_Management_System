# Points Management System

A cross-platform mobile app for offline clothing store loyalty/points management. Supports Android, iOS, and Web.

---

## Features

### Entry Tab
- Add customer info: name, clothing size, points (required); gender, birthday, phone (optional)
- Camera/gallery OCR: photograph a membership card or handwritten receipt to auto-fill the form
- OCR-filled fields are highlighted; low-confidence fields show a warning icon

### Query Tab
- Filter by points range: All / ≥500 / ≥800 / ≥1000 / custom range
- Filter by birth month
- Milestone badges:
  - Bronze: ≥ 500 pts
  - Silver: ≥ 800 pts
  - Gold: ≥ 1000 pts
- Tap any customer to view details and edit inline

### Profile Tab
- Displays store name; additional items to be added later

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter 3.27.4 | Cross-platform UI framework |
| sqflite | Local SQLite database (Android / iOS) |
| sqflite_common_ffi_web | SQLite support for Web |
| Provider | State management |
| image_picker | Camera / gallery access |
| http | OCR API requests |
| intl | Date formatting |

---

## Project Structure

```
lib/
├── config/
│   └── app_config.dart          # OCR API config (add your keys here)
├── models/
│   └── customer.dart            # Customer model + milestone logic
├── services/
│   ├── database_service.dart    # Local SQLite CRUD
│   ├── ocr_service.dart         # OCR image recognition
│   └── auth_service.dart        # Auth stub (reserved for multi-store)
├── providers/
│   ├── customer_provider.dart   # Global customer list state
│   └── store_provider.dart      # Store context (reserved)
├── screens/
│   ├── entry/entry_screen.dart  # Entry tab
│   ├── query/query_screen.dart  # Query tab
│   ├── query/detail_screen.dart # Detail / edit screen
│   └── profile/profile_screen.dart # Profile tab
└── widgets/
    ├── milestone_badge.dart     # Bronze / silver / gold badge
    └── customer_list_tile.dart  # Customer list row
```

---

## Getting Started

### Requirements
- Flutter 3.27.4+
- Android SDK (for Android) / Xcode on macOS (for iOS)

### Install dependencies

```bash
flutter pub get
```

### Run on Web (development)

```bash
# First-time setup only
dart run sqflite_common_ffi_web:setup

flutter run -d chrome
```

### Run on Android

```bash
flutter run -d <device-id>
```

---

## OCR Configuration

Edit `lib/config/app_config.dart` and replace the placeholders with your OCR service credentials:

```dart
static const String ocrEndpoint = 'https://your-ocr-api.com/recognize';
static const String ocrApiKey = 'your-api-key';
```

---

## Data Storage

All data is stored locally on the device. The app works fully offline; only OCR requires a network connection.

| Platform | Storage location |
|---|---|
| Android | `/data/data/<package>/databases/clothing_points.db` |
| iOS | App sandbox Documents directory |
| Web | Browser IndexedDB |

---

## Roadmap

- [ ] Multi-store management (`store_provider.dart` stub ready)
- [ ] User login (`auth_service.dart` stub ready)
- [ ] Cloud data sync
- [ ] Points transaction history
- [ ] Data export (Excel / CSV)
