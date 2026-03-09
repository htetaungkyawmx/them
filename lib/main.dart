import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/config/routes.dart';
import 'package:them_dating_app/core/constants/app_strings.dart';
import 'package:them_dating_app/core/themes/light_theme.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/providers/chat_provider.dart';
import 'package:them_dating_app/providers/match_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDpHBtnn8NgTnVbpkxqhXmIZG5Z8xc9Blg",
        appId: "1:176595574923:android:05df99ee9bda4d4c90f48e",
        messagingSenderId: "176595574923",
        projectId: "them-dating-app",
        storageBucket: "them-dating-app.firebasestorage.app",
      ),
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: LightTheme.theme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}