import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppAnimations {
  // Page Transitions
  static PageTransitionsTheme pageTransitions = const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  // Hero Animations
  static const heroAnimation = Duration(milliseconds: 300);

  // Custom Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  // Slide Transitions
  static SlideTransition slideFromRight(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  static SlideTransition slideFromBottom(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  // Fade Transitions
  static FadeTransition fadeIn(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      ),
      child: child,
    );
  }

  // Scale Transitions
  static ScaleTransition scaleIn(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      ),
      child: child,
    );
  }
}