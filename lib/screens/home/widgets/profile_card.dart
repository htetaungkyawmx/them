import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/data/models/user_model.dart';

class ProfileCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLike;
  final VoidCallback onPass;

  const ProfileCard({
    super.key,
    required this.user,
    required this.onLike,
    required this.onPass,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Image
          Expanded(
            child: Stack(
              children: [
                // Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.user.photos.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: widget.user.photos[_currentImageIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                // Image indicators
                if (widget.user.photos.length > 1)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: List.generate(
                        widget.user.photos.length,
                            (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Navigation buttons
                if (widget.user.photos.length > 1)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentImageIndex = _currentImageIndex > 0
                                  ? _currentImageIndex - 1
                                  : widget.user.photos.length - 1;
                            });
                          },
                          child: Container(
                            height: double.infinity,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentImageIndex = _currentImageIndex < widget.user.photos.length - 1
                                  ? _currentImageIndex + 1
                                  : 0;
                            });
                          },
                          child: Container(
                            height: double.infinity,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                // User info overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.user.name ?? 'User'}, ${widget.user.age ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.user.bio != null)
                          Text(
                            widget.user.bio!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close,
                color: Colors.red,
                onPressed: widget.onPass,
                size: 60,
              ),
              _buildActionButton(
                icon: Icons.favorite,
                color: Colors.green,
                onPressed: widget.onLike,
                size: 70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
        onPressed: onPressed,
      ),
    );
  }
}