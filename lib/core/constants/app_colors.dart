import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF6B6B); // Soft Red
  static const Color secondary = Color(0xFF4ECDC4); // Mint
  static const Color accent = Color(0xFFFFE66D); // Soft Yellow

  // Background Colors
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}