import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../themes/app_theme.dart';

class ProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool isOnline;
  final bool isVerified;
  final VoidCallback? onTap;

  const ProfileImage({
    super.key,
    this.imageUrl,
    this.radius = 30,
    this.isOnline = false,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isVerified ? AppColors.primaryGradient : null,
              border: isVerified
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            padding: isVerified ? const EdgeInsets.all(2) : null,
            child: CircleAvatar(
              radius: radius - (isVerified ? 2 : 0),
              backgroundColor: AppColors.surface,
              backgroundImage: imageUrl != null
                  ? CachedNetworkImageProvider(imageUrl!)
                  : null,
              child: imageUrl == null
                  ? Icon(
                Icons.person,
                size: radius,
                color: AppColors.textSecondary,
              )
                  : null,
            ),
          ),
          if (isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: radius * 0.4,
                height: radius * 0.4,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          if (isVerified)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: radius * 0.4,
                height: radius * 0.4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}