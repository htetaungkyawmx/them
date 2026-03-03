import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:them/features/auth/presentation/controllers/auth_controller.dart';
import 'package:them/features/auth/presentation/screens/login_screen.dart';
import 'package:them/features/auth/presentation/screens/signup_screen.dart';
import 'package:them/features/chat/controllers/chat_controller.dart';
import 'package:them/features/home/presentation/screens/home_screen.dart';
import 'package:them/features/matching/presentation/controllers/matching_controller.dart';
import 'package:them/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:them/features/profile/presentation/controllers/profile_controller.dart';

import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      defaultTransition: Transition.cupertino,
      transitionDuration: AppConstants.animationNormal,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/signup',
          page: () => SignupScreen(),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize all controllers
    Get.put(AuthController());
    Get.put(ChatController());
    Get.put(ProfileController());
    Get.put(MatchingController());
    Get.put(NotificationsController());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
      final authController = Get.find<AuthController>();
      if (authController.user.value != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'သင့်အတွက် အထူးသင့်တော်ဆုံးသူကို ရှာဖွေလိုက်ပါ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}