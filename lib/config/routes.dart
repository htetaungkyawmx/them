import 'package:flutter/material.dart';
import 'package:them_dating_app/screens/auth/login_screen.dart';
import 'package:them_dating_app/screens/auth/otp_screen.dart';
import 'package:them_dating_app/screens/auth/register_screen.dart';
import 'package:them_dating_app/screens/chat/chat_list_screen.dart';
import 'package:them_dating_app/screens/chat/chat_screen.dart';
import 'package:them_dating_app/screens/home/home_screen.dart';
import 'package:them_dating_app/screens/home/profile_detail_screen.dart';
import 'package:them_dating_app/screens/matches/matches_screen.dart';
import 'package:them_dating_app/screens/profile/edit_profile_screen.dart';
import 'package:them_dating_app/screens/profile/profile_screen.dart';
import 'package:them_dating_app/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String profileDetail = '/profile-detail';
  static const String matches = '/matches';
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case otp:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => OTPScreen(phoneNumber: args['phoneNumber']!),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profileDetail:
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProfileDetailScreen(userId: userId),
        );
      case matches:
        return MaterialPageRoute(builder: (_) => const MatchesScreen());
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            matchId: args['matchId'],
            userId: args['userId'],
            userName: args['userName'],
          ),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}