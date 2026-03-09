import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String mobileNumber;
  final String displayName;
  final AuthService authService;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.mobileNumber,
    required this.displayName,
    required this.authService,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late List<TextEditingController> _otpControllers;
  final FocusNode _firstFocus = FocusNode();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  bool _canResend = false;
  bool _isOTPComplete = false; // Track if all 6 digits are entered

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _startResendCountdown();

    // Listen to OTP controllers for completion tracking
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
    // Check if all 6 digits are entered
    bool isComplete = _otpControllers.every(
      (controller) => controller.text.isNotEmpty,
    );
    if (isComplete != _isOTPComplete) {
      setState(() {
        _isOTPComplete = isComplete;
      });
    }
  }

  void _startResendCountdown() {
    _resendCountdown = 60; // 60 seconds countdown
    _canResend = false;

    _startCountdownTimer();
  }

  void _startCountdownTimer() async {
    while (_resendCountdown > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          _canResend = true;
        }
      });
    }
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

  String _getOTPCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _onOTPChanged(String value, int index) {
    // Only allow digits
    if (value.isNotEmpty && !RegExp(r'^\d$').hasMatch(value)) {
      _otpControllers[index].clear();
      return;
    }

    // Auto-focus next field or submit if complete
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus();
    } else if (value.isNotEmpty && index == 5) {
      // All fields filled, auto-verify
      String otp = _getOTPCode();
      if (otp.length == 6 && !_isLoading) {
        _verifyOTP();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTPCode();

    // Validate OTP format
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete 6-digit code')),
      );
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code must contain only numbers'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Show verification in progress
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifying code...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Check if OTP is test code 000000
      if (otp == '000000') {
        // Test mode - automatically verify without calling auth service
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        // Production mode - call auth service for verification
        await widget.authService.verifyOTP(
          otp: otp,
          email: widget.email,
          mobileNumber: widget.mobileNumber,
          displayName: widget.displayName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      // Show resending message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resending verification code...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Resend OTP with delivery confirmation
      bool otpResent = await widget.authService.resendOTP(
        deliveryCallback: (bool success, String? error) {
          if (!mounted) return;

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification code resent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to resend code: ${error ?? 'Unknown error'}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      if (otpResent && mounted) {
        // Clear OTP fields and refocus
        for (var controller in _otpControllers) {
          controller.clear();
        }
        FocusScope.of(context).requestFocus(_firstFocus);

        // Restart countdown
        _startResendCountdown();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP'), elevation: 0),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Test Mode: Enter 000000 to verify',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        for (int i = 0; i < 6; i++) {
                          _otpControllers[i].text = '0';
                        }
                        _checkOTPCompletion();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Fill 000000',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
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
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onOTPChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: (_isLoading || !_isOTPComplete) ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isOTPComplete ? 'Verify OTP' : 'Enter complete OTP',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      _canResend
                          ? "Didn't receive the code?"
                          : "Resend code in ${_resendCountdown}s",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: (_isResending || !_canResend)
                          ? null
                          : _resendOTP,
                      child: _isResending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _canResend
                                  ? 'Resend OTP'
                                  : 'Resend in ${_resendCountdown}s',
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
