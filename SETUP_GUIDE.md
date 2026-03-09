# Tutoring App - Setup Guide

## Overview
This Flutter application provides:
- **Phone Number OTP Authentication** - Login with email, mobile, and OTP verification
- **Student Management** - Add, edit, delete students with name, mobile number, and role
- **Firebase Integration** - Real-time student data sync with Firestore
- **Role-Based Classification** - Pre-defined and custom student levels

## Prerequisites
- Flutter SDK (3.11.0 or higher)
- Dart SDK
- Firebase Account
- Android Studio / Xcode (for device testing)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a new project"
3. Enter project name: `tutoring-app`
4. Click "Create project"
5. Wait for project creation to complete

## Step 2: Setup Firebase Authentication

1. In Firebase Console, go to **Authentication** > **Get started**
2. Click on **Phone** sign-in method
3. Enable it and save
4. Go to **Settings** > **Project settings**
5. Copy your **Project ID** and **Web API Key**

## Step 3: Setup Cloud Firestore

1. In Firebase Console, click **Build** > **Firestore Database**
2. Click "Create database"
3. Select **Start in test mode** (for development)
4. Choose your region and create
5. Once created, go to **Rules** tab and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    match /students/{document=**} {
      allow read, write: if request.auth != null && 
        resource.data.uid == request.auth.uid;
    }
  }
}
```

## Step 4: Register Android App

1. In Firebase Console, click **Project settings** > **Your apps**
2. Click **Add app** > **Android**
3. Enter package name: `com.example.turtoring_apps`
4. Download `google-services.json`
5. Place the file at: `android/app/google-services.json`

## Step 5: Register iOS App (Optional)

1. In Firebase Console, click **Add app** > **iOS**
2. Enter bundle ID: `com.example.tutoringApps`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/` (drag into Xcode)

## Step 6: Update Firebase Configuration

1. Open `lib/firebase_options.dart`
2. Replace placeholder values with your Firebase credentials:
   - `YOUR_WEB_API_KEY` - From Firebase > Settings > Web API Key
   - `YOUR_PROJECT_ID` - Your Firebase Project ID
   - And other platform-specific keys

## Step 7: Get Flutter Dependencies

Run in your project directory:

```bash
flutter pub get
```

## Step 8: Run the Application

### Android
```bash
flutter run
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d web
```

## Firebase Firestore Schema

### users Collection
```
users/
├── {uid}
│   ├── uid: string
│   ├── email: string
│   ├── mobileNumber: string
│   ├── displayName: string
│   └── createdAt: timestamp
```

### students Collection
```
students/
├── {documentId}
│   ├── id: string
│   ├── uid: string (user reference)
│   ├── name: string
│   ├── mobileNumber: string
│   ├── role: string (Primary, Secondary, Advanced)
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
├── models/
│   ├── user_model.dart               # User data model
│   └── student_model.dart            # Student data model
├── services/
│   ├── auth_service.dart             # Authentication logic
│   └── student_service.dart          # Student CRUD operations
└── screens/
    ├── login_screen.dart             # Login with email & mobile
    ├── otp_verification_screen.dart  # OTP verification
    ├── home_screen.dart              # Student list
    └── add_student_screen.dart       # Add/Edit student
```

## Features

### Authentication
- ✅ Phone number verification with OTP
- ✅ Email collection during signup
- ✅ Display name customization
- ✅ Persistent login state
- ✅ Logout functionality

### Student Management
- ✅ Add new students
- ✅ Edit existing students
- ✅ Delete students
- ✅ Real-time student list updates
- ✅ Role/Level categorization
- ✅ Mobile number validation

### Data Storage
- ✅ Firebase Authentication integration
- ✅ Firestore real-time database
- ✅ User-specific data isolation
- ✅ Automatic timestamps

## Testing

### Test Account
Use any 10-digit mobile number for testing. Firebase will auto-verify in test mode.

### Test Cases
1. **Login**: Enter email, mobile, and send OTP
2. **Verification**: Enter 6-digit OTP code
3. **Add Student**: Create a new student record
4. **Edit Student**: Modify student details
5. **Delete Student**: Remove a student
6. **Logout**: Sign out and return to login

## Troubleshooting

### Issue: "google-services.json not found"
- Ensure `android/app/google-services.json` exists
- Run `flutter clean` then `flutter pub get`

### Issue: "Firebase initialization failed"
- Check Firebase credentials in `firebase_options.dart`
- Verify your Firebase project is active
- Ensure network connectivity

### Issue: "Phone verification not working"
- Firebase phone auth requires running on real device (not emulator for Android)
- For emulator testing, use Firebase Test Numbers
- Check that phone number format is correct (+91 for India)

### Issue: "Firestore permission denied"
- Verify Firestore Rules are set correctly
- Ensure user is authenticated before accessing Firestore
- Check that `uid` in rules matches authenticated user

## Firebase Test Phone Numbers

For testing phone authentication:
- +1 650-253-0000 (OTP: 000000)
- +1 650-253-0000 onwards (various numbers)

## Security Notes

⚠️ **Important for Production**:
1. Change Firestore rules from test mode to production rules
2. Enable authentication requirements
3. Use security rules to restrict data access
4. Implement proper error handling
5. Add input validation and sanitization
6. Use Firebase Security Rules for backend validation

## API Reference

### AuthService
```dart
await authService.sendOTP(phoneNumber);
await authService.verifyOTP(otp, email, mobileNumber, displayName);
await authService.logout();
Future<User?> getCurrentUser();
bool isUserLoggedIn();
```

### StudentService
```dart
await studentService.addStudent(student);
await studentService.updateStudent(student);
await studentService.deleteStudent(studentId);
Future<List<Student>> getStudentsByUser(uid);
Stream<List<Student>> getStudentsStream(uid);
```

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Firebase console logs
3. Verify all configuration steps
4. Check Flutter doctor: `flutter doctor`

---

**Last Updated**: March 2026
**Version**: 1.0.0
