# Tutoring App

A Flutter application for managing tutoring students with OTP-based authentication and Firebase integration.

## Features

- 🔐 **Secure Authentication**: Phone number verification with OTP
- 📱 **Student Management**: Add, edit, and delete students
- 🏆 **Role Classification**: Categorize students by level (Primary, Secondary, Advanced)
- 🔄 **Real-time Sync**: Firebase Firestore integration for instant updates
- 👤 **User Profiles**: Email and display name management
- 📊 **Contact Information**: Store and manage student mobile numbers

## Getting Started

### Prerequisites
- Flutter SDK 3.11.0+
- Firebase Account
- Android/iOS device or emulator

### Quick Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Setup Firebase** (See [SETUP_GUIDE.md](SETUP_GUIDE.md))
   - Create Firebase project
   - Configure authentication and Firestore
   - Update `lib/firebase_options.dart`

3. **Run the App**
   ```bash
   flutter run
   ```

## Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete Firebase and development setup
- **[Architecture](#project-structure)** - Project structure and organization

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
├── models/                            # Data models
│   ├── user_model.dart
│   └── student_model.dart
├── services/                          # Business logic
│   ├── auth_service.dart             # Authentication
│   └── student_service.dart          # Data management
└── screens/                           # UI screens
    ├── login_screen.dart
    ├── otp_verification_screen.dart
    ├── home_screen.dart
    └── add_student_screen.dart
```

## Dependencies

- firebase_core, firebase_auth, cloud_firestore
- provider, intl

See [pubspec.yaml](pubspec.yaml) for complete list.

## Usage

1. **Login**: Enter email, mobile, and verify OTP
2. **Add Students**: Manage student records
3. **Edit/Delete**: Modify or remove students
4. **Logout**: Sign out from profile menu

## Security

- Firestore Rules enforce user-level data isolation
- Phone verification for authentication
- Real-time database with automatic timestamps

## Support

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for troubleshooting and detailed setup instructions.

---

**Version**: 1.0.0  
**Last Updated**: March 2026
