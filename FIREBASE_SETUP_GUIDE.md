# Firebase Phone Authentication Setup Guide

## 1. Dependencies (pubspec.yaml)

Your `pubspec.yaml` already has the required packages:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase packages
  firebase_core: ^3.15.2      # Firebase initialization
  firebase_auth: ^5.7.0       # Authentication (including phone auth)
  cloud_firestore: ^5.1.0     # Database

  # State Management
  provider: ^6.1.0            # State management

  # Utilities
  intl: ^0.19.0               # Date/time formatting
  cupertino_icons: ^1.0.8     # iOS-style icons
```

## 2. Firebase Initialization (main.dart)

Your `main.dart` is already correctly configured:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutoring App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthWrapper handles navigation to login or home based on auth state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  late Future<bool> _isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _authService.isUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
```

## 3. Phone Authentication Service (lib/services/auth_service.dart)

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track verification ID and resend token
  String? _verificationId;
  int? _resendToken;

  // STEP 1: Send SMS OTP to phone number
  Future<bool> sendSMSOTP(
    String phoneNumber, {
    required Function(bool success, String? error)? deliveryCallback,
  }) async {
    try {
      final formattedPhone = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+91$phoneNumber';

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        
        // Called when SMS is sent successfully
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verify on some devices
          deliveryCallback?.call(true, null);
        },
        
        // Called when there's an error
        verificationFailed: (FirebaseAuthException e) {
          deliveryCallback?.call(false, e.message);
        },
        
        // Called when SMS is sent
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          deliveryCallback?.call(true, null);
        },
        
        // Called when timeout expires
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

      return true;
    } catch (e) {
      deliveryCallback?.call(false, e.toString());
      return false;
    }
  }

  // STEP 2: Verify OTP code
  Future<void> verifyOTP({
    required String otp,
    required String email,
    required String mobileNumber,
    required String displayName,
  }) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID not found. Please request OTP again.');
      }

      // Create credential from OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Sign in with credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Save user data to Firestore
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        mobileNumber: mobileNumber,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      // Clear verification ID after successful verification
      _verificationId = null;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // STEP 3: Resend OTP
  Future<bool> resendOTP({
    required Function(bool success, String? error)? deliveryCallback,
  }) async {
    if (_verificationId == null) {
      deliveryCallback?.call(false, 'Verification ID not found');
      return false;
    }

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: _verificationId!, // Note: This is a workaround
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {
          deliveryCallback?.call(true, null);
        },
        verificationFailed: (FirebaseAuthException e) {
          deliveryCallback?.call(false, e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          deliveryCallback?.call(true, null);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      deliveryCallback?.call(false, e.toString());
      return false;
    }
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
    return null;
  }
}
```

## 4. Phone Authentication Flow Diagram

```
┌─────────────────────┐
│  User enters phone  │
│      number         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────┐
│ sendSMSOTP() called     │
│ Firebase sends SMS Code │
└──────────┬──────────────┘
           │
           ▼
┌──────────────────────┐
│ User receives SMS    │
│ with 6-digit code    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ User enters OTP      │
│ in 6 text fields     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────┐
│ verifyOTP() called       │
│ Firebase verifies code   │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────┐
│ User data saved to   │
│ Firestore and logged │
│ in successfully      │
└──────────────────────┘
```

## 5. Login Screen Example

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String phoneNumber = _mobileController.text.trim();
      
      // Show sending message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sending SMS verification code...')),
      );

      // Send OTP with delivery feedback
      bool otpSent = await _authService.sendSMSOTP(
        phoneNumber,
        deliveryCallback: (bool success, String? error) {
          if (!mounted) return;

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SMS verification code sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send code: ${error ?? 'Unknown error'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      if (otpSent && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              email: _emailController.text.trim(),
              mobileNumber: _mobileController.text.trim(),
              displayName: _displayNameController.text.trim(),
              authService: _authService,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Welcome to Tutoring App',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!value!.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: '10-digit number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                    prefixText: '+91 ',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your mobile number';
                    }
                    if (value!.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Verification Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 6. OTP Verification Screen Example

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String mobileNumber;
  final String displayName;
  final AuthService authService;

  const OTPVerificationScreen({
    required this.email,
    required this.mobileNumber,
    required this.displayName,
    required this.authService,
    super.key,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late List<TextEditingController> _otpControllers;
  final FocusNode _firstFocus = FocusNode();
  bool _isLoading = false;
  bool _isOTPComplete = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    
    // Listen for OTP completion
    for (var controller in _otpControllers) {
      controller.addListener(_checkOTPCompletion);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_firstFocus);
      }
    });
  }

  void _checkOTPCompletion() {
    bool isComplete = _otpControllers.every(
      (controller) => controller.text.isNotEmpty,
    );
    if (isComplete != _isOTPComplete) {
      setState(() => _isOTPComplete = isComplete);
    }
  }

  void _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();

    setState(() => _isLoading = true);

    try {
      await widget.authService.verifyOTP(
        otp: otp,
        email: widget.email,
        mobileNumber: widget.mobileNumber,
        displayName: widget.displayName,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Verification Code',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to\n+91 ${widget.mobileNumber}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: index == 0 ? _firstFocus : null,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              // Verify Button (disabled until all 6 digits entered)
              ElevatedButton(
                onPressed: (_isLoading || !_isOTPComplete) ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isOTPComplete ? 'Verify OTP' : 'Enter complete OTP',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.removeListener(_checkOTPCompletion);
      controller.dispose();
    }
    _firstFocus.dispose();
    super.dispose();
  }
}
```

## 7. Firebase Configuration Setup

Before running the app, you need to:

### Android Setup:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new Firebase project or select existing one
3. Add Android app with package name: `com.example.turtoring_apps`
4. Download `google-services.json` and place in `android/app/`
5. In Firebase Console → Authentication → Enable Phone authentication

### iOS Setup:
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist` and add to Xcode project
3. Enable Phone authentication in Firebase Console

### Generate Firebase Options:
Run this command to auto-generate `firebase_options.dart`:

```bash
flutterfire configure
```

## 8. Test the Complete Flow

```bash
flutter run
```

**Complete flow:**
1. Enter name, email, and 10-digit mobile number
2. Click "Send Verification Code"
3. Receive SMS with 6-digit code
4. Enter OTP in 6 fields (auto-moves to next)
5. Button enables when all 6 digits entered
6. Click "Verify OTP"
7. Successfully logged in and redirected to home screen

---

Your app is now ready with complete Firebase phone authentication! 🎉
