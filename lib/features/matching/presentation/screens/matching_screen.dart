import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/profile_image.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/data/models/profile_model.dart';
import '../controllers/matching_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MatchingController matchingController = Get.find<MatchingController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    matchingController.loadProfiles();
    matchingController.loadLikes();
    matchingController.loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ရှာဖွေမည်'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ရှာဖွေရန်'),
            Tab(text: 'စိတ်ဝင်စားမှုများ'),
            Tab(text: 'ကိုက်ညီမှုများ'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildLikesTab(),
          _buildMatchesTab(),
        ],
      ),
    );
  }

  // Discover Tab - Swipe Cards
  Widget _buildDiscoverTab() {
    return Obx(() {
      if (matchingController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (matchingController.profiles.isEmpty) {
        return _buildEmptyState(
          icon: Icons.explore_outlined,
          title: 'ရှာဖွေရန် ပရိုဖိုင်များ မရှိပါ',
          message: 'ကျေးဇူးပြု၍ ရှာဖွေမှုအကွာအဝေးကို ချဲ့ထွင်ပါ သို့မဟုတ် နောက်မှ ပြန်လည်ကြိုးစားပါ',
        );
      }

      return Stack(
        children: [
          // Cards Stack
          Positioned.fill(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: matchingController.profiles.length,
              onPageChanged: (index) {
                // Handle page change
              },
              itemBuilder: (context, index) {
                final profile = matchingController.profiles[index];
                return _buildProfileCard(profile);
              },
            ),
          ),

          // Action Buttons
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pass Button
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 30,
                    ),
                    onPressed: () {
                      matchingController.passProfile(
                        matchingController.profiles.first.id,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 20),

                // Super Like Button
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.star,
                      color: AppColors.primary,
                      size: 25,
                    ),
                    onPressed: () {
                      matchingController.superLikeProfile(
                        matchingController.profiles.first.id,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 20),

                // Like Button
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      matchingController.likeProfile(
                        matchingController.profiles.first.id,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProfileCard(ProfileModel profile) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        child: Stack(
          children: [
            // Background Image
            if (profile.photos.isNotEmpty)
              CachedNetworkImage(
                imageUrl: profile.photos.first,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Profile Info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Age
                  Row(
                    children: [
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (profile.age != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${profile.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                      if (profile.isVerified)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(4),
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
                    ],
                  ),

                  // Location
                  if (profile.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.location!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Bio
                  if (profile.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  // Interests
                  if (profile.interests.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: profile.interests.take(3).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Likes Tab
  Widget _buildLikesTab() {
    return Obx(() {
      if (matchingController.isLoadingLikes.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (matchingController.likes.isEmpty) {
        return _buildEmptyState(
          icon: Icons.favorite_outline,
          title: 'စိတ်ဝင်စားမှုများ မရှိသေးပါ',
          message: 'သင့်ကို စိတ်ဝင်စားသူများ ဤနေရာတွင် ပေါ်လာပါမည်',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matchingController.likes.length,
        itemBuilder: (context, index) {
          final like = matchingController.likes[index];
          return _buildLikeItem(like);
        },
      );
    });
  }

  Widget _buildLikeItem(dynamic like) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          ProfileImage(
            imageUrl: like['photoUrl'],
            radius: 30,
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  like['displayName'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${like['age'] ?? '?'} နှစ် • ${like['location'] ?? 'မသိ'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () {
                    matchingController.rejectLike(like['id']);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    matchingController.acceptLike(like['id']);
                    _showMatchDialog(like);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Matches Tab
  Widget _buildMatchesTab() {
    return Obx(() {
      if (matchingController.isLoadingMatches.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (matchingController.matches.isEmpty) {
        return _buildEmptyState(
          icon: Icons.people_outline,
          title: 'ကိုက်ညီမှုများ မရှိသေးပါ',
          message: 'သင်နှင့် ကိုက်ညီသူများ ဤနေရာတွင် ပေါ်လာပါမည်',
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: matchingController.matches.length,
        itemBuilder: (context, index) {
          final match = matchingController.matches[index];
          return _buildMatchItem(match);
        },
      );
    });
  }

  Widget _buildMatchItem(dynamic match) {
    return InkWell(
      onTap: () {
        // Navigate to chat
        Get.toNamed('/chat', arguments: match);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: match['photoUrl'] != null
                    ? CachedNetworkImage(
                  imageUrl: match['photoUrl'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    match['displayName'] ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    match['lastActive'] != null
                        ? _formatLastActive(DateTime.parse(match['lastActive']))
                        : 'အွန်လိုင်း',
                    style: TextStyle(
                      fontSize: 12,
                      color: match['isOnline'] == true
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'အခုလေးတင်';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} မိနစ်က';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} နာရီက';
    } else {
      return '${difference.inDays} ရက်က';
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMatchDialog(dynamic like) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'It\'s a Match!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'သင်နှင့် ဤသူသည် တစ်ဦးကိုတစ်ဦး စိတ်ဝင်စားကြသည်',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Profile Images
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProfileImage(
                    imageUrl: Get.find<AuthController>().user.value?.photoURL,
                    radius: 40,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  ProfileImage(
                    imageUrl: like['photoUrl'],
                    radius: 40,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'ဆက်လက်ရှာဖွေမည်',
                      onPressed: () {
                        Get.back();
                      },
                      type: ButtonType.outline,
                      size: ButtonSize.small,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'စကားစမည်',
                      onPressed: () {
                        Get.back();
                        // Navigate to chat
                      },
                      type: ButtonType.primary,
                      size: ButtonSize.small,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}