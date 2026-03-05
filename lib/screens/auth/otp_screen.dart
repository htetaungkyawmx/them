import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/config/routes.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/widgets/custom_button.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _verificationId = '';

  @override
  void initState() {
    super.initState();
    // You'll get verificationId from login screen
    // For now, we'll simulate
  }

  Future<void> _verifyOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOTP(
      _verificationId,
      _pinController.text,
    );

    if (success && mounted) {
      // Check if user profile exists
      if (authProvider.currentUser == null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.register,
          arguments: {'phoneNumber': widget.phoneNumber},
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Invalid OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Text(
              'Enter Verification Code',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We\'ve sent a 6-digit code to ${widget.phoneNumber}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),

            // OTP Input
            Center(
              child: Pinput(
                controller: _pinController,
                length: 6,
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onCompleted: (pin) => _verifyOTP(),
              ),
            ),

            const SizedBox(height: 30),

            // Verify Button
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return CustomButton(
                  text: 'Verify',
                  onPressed: _verifyOTP,
                  isLoading: provider.isLoading,
                );
              },
            ),

            const SizedBox(height: 20),

            // Resend Code
            Center(
              child: TextButton(
                onPressed: () {
                  // Resend OTP
                  Provider.of<AuthProvider>(context, listen: false)
                      .loginWithPhone(widget.phoneNumber);
                },
                child: Text(
                  'Resend Code',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}