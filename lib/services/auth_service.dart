import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;
  bool _otpSent = false;
  String? _lastPhoneNumber;
  final bool _isTestMode = true; // Enable test mode for development

  // OTP delivery status callback
  Function(bool success, String? error)? _otpDeliveryCallback;

  // Send SMS OTP only (no voice calls) with delivery confirmation
  Future<bool> sendSMSOTP(
    String phoneNumber, {
    Function(bool success, String? error)? deliveryCallback,
  }) async {
    try {
      _otpDeliveryCallback = deliveryCallback;
      _otpSent = false;
      _lastPhoneNumber = phoneNumber;

      if (_isTestMode) {
        // Test mode: Simulate OTP sending
        await Future.delayed(const Duration(seconds: 1));
        _verificationId = 'test_verification_id';
        _otpSent = true;
        _otpDeliveryCallback?.call(
          true,
          'Test OTP sent successfully (use 000000)',
        );
        return true;
      }

      // Firebase Auth sends SMS by default, no voice call configuration needed
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(minutes: 2),
        // SMS only - no voice call fallback
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
              // Auto-verification completed (rare, but possible)
              _otpSent = true;
              _otpDeliveryCallback?.call(true, 'SMS sent and auto-verified');
            },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          _otpSent = false;
          String errorMessage = _getReadableErrorMessage(e);
          _otpDeliveryCallback?.call(false, errorMessage);
          throw Exception('SMS verification failed: $errorMessage');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _otpSent = true;
          _otpDeliveryCallback?.call(true, 'SMS sent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          // SMS sent but auto-retrieval timed out - this is normal
          if (!_otpSent) {
            _otpSent = true;
            _otpDeliveryCallback?.call(
              true,
              'SMS sent (auto-retrieval timeout)',
            );
          }
        },
      );

      // Wait briefly for delivery confirmation
      await Future.delayed(const Duration(seconds: 1));

      return _otpSent;
    } catch (e) {
      _otpSent = false;
      _otpDeliveryCallback?.call(false, e.toString());
      rethrow;
    }
  }

  // Legacy method for backward compatibility
  Future<bool> sendOTP(
    String phoneNumber, {
    Function(bool success, String? error)? deliveryCallback,
  }) async {
    return sendSMSOTP(phoneNumber, deliveryCallback: deliveryCallback);
  }

  // Get readable error messages
  String _getReadableErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      case 'missing-phone-number':
        return 'Phone number is required';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'code-expired':
        return 'Verification code has expired';
      default:
        return e.message ?? 'Unknown error occurred';
    }
  }

  // Verify OTP and Login with enhanced validation
  Future<User?> verifyOTP({
    required String otp,
    required String email,
    required String mobileNumber,
    required String displayName,
  }) async {
    try {
      // Validate OTP format
      if (otp.isEmpty) {
        throw Exception('Please enter the verification code');
      }

      if (otp.length != 6) {
        throw Exception('Verification code must be 6 digits');
      }

      if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
        throw Exception('Verification code must contain only numbers');
      }

      if (_verificationId == null) {
        throw Exception(
          'Verification session expired. Please request a new code.',
        );
      }

      if (!_otpSent) {
        throw Exception('No verification code was sent. Please try again.');
      }

      firebase_auth.UserCredential userCredential;

      if (_isTestMode && otp == '000000') {
        // Test mode: Create anonymous user or use a test account
        try {
          // Try to sign in anonymously for testing
          userCredential = await _firebaseAuth.signInAnonymously();
        } catch (e) {
          // If anonymous sign-in fails, create a test user
          final testEmail = 'test_$mobileNumber@example.com';
          final testPassword = 'testpassword123';

          try {
            // Try to sign in with test account
            userCredential = await _firebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            );
          } catch (e) {
            // Create test account if it doesn't exist
            userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            );
          }
        }
      } else {
        // Normal Firebase Auth verification
        // Create credential
        final credential = firebase_auth.PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );

        // Sign in with credential
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Authentication failed. Please try again.');
      }

      // Save user data to Firestore
      final user = User(
        uid: firebaseUser.uid,
        email: email,
        mobileNumber: mobileNumber,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toMap(), SetOptions(merge: true));

      // Clear verification state after successful login
      _clearVerificationState();

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = _getReadableErrorMessage(e);
      throw Exception('Verification failed: $errorMessage');
    } catch (e) {
      rethrow;
    }
  }

  // Clear verification state
  void _clearVerificationState() {
    _verificationId = null;
    _otpSent = false;
    _lastPhoneNumber = null;
    _otpDeliveryCallback = null;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _clearVerificationState();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final userData = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (userData.exists) {
          return User.fromMap(userData.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is authenticated
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Check if OTP was sent successfully
  bool get isOtpSent => _otpSent;

  // Get last phone number used for OTP
  String? get lastPhoneNumber => _lastPhoneNumber;

  // Get current user UID
  String? getCurrentUserUID() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Resend OTP with delivery confirmation
  Future<bool> resendOTP({
    Function(bool success, String? error)? deliveryCallback,
  }) async {
    if (_lastPhoneNumber == null) {
      throw Exception(
        'No phone number available for resend. Please start over.',
      );
    }

    // Clear previous verification state
    _clearVerificationState();

    return await sendOTP(_lastPhoneNumber!, deliveryCallback: deliveryCallback);
  }
}
