import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;

  const LoadingWidget({
    super.key,
    this.message,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: content,
      );
    }

    return content;
  }
}