import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/config/routes.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/core/constants/app_strings.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/widgets/custom_button.dart';
import 'package:them_dating_app/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Format phone number (add +95 for Myanmar)
      String phone = _phoneController.text.trim();
      if (!phone.startsWith('+')) {
        if (phone.startsWith('0')) {
          phone = '+95${phone.substring(1)}';
        } else {
          phone = '+95$phone';
        }
      }

      await authProvider.loginWithPhone(phone);

      if (authProvider.error == null) {
        // Navigate to OTP screen
        Navigator.pushNamed(
          context,
          AppRoutes.otp,
          arguments: {'phoneNumber': phone},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Logo and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Find your perfect match',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Form
              Form(
                key: _formKey,
                child: CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefix: const Icon(Icons.phone),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 9) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Login Button
              Consumer<AuthProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Continue',
                    onPressed: _handleLogin,
                    isLoading: provider.isLoading,
                  );
                },
              ),
              const SizedBox(height: 20),
              // Terms
              Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
    _phoneController.dispose();
    super.dispose();
  }
}