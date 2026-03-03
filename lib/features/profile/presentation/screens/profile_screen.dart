import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/profile_image.dart';
import '../../../core/themes/app_theme.dart';
import '../controllers/profile_controller.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပရိုဖိုင်'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Get.to(() => SettingsScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final profile = profileController.profile.value;
        if (profile == null) {
          return _buildErrorState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(profile),

              const SizedBox(height: 24),

              // Stats Row
              _buildStatsRow(profile),

              const SizedBox(height: 24),

              // Bio Section
              _buildBioSection(profile),

              const SizedBox(height: 24),

              // Photos Section
              _buildPhotosSection(profile),

              const SizedBox(height: 24),

              // Interests Section
              _buildInterestsSection(profile),

              const SizedBox(height: 24),

              // Basic Info Section
              _buildBasicInfoSection(profile),

              const SizedBox(height: 24),

              // Edit Profile Button
              CustomButton(
                text: AppStrings.editProfile,
                onPressed: () {
                  Get.to(() => EditProfileScreen(profile: profile));
                },
                type: ButtonType.outline,
                size: ButtonSize.medium,
                isFullWidth: true,
              ),

              const SizedBox(height: 16),

              // Sign Out Button
              CustomButton(
                text: 'ထွက်မည်',
                onPressed: () {
                  _showSignOutDialog();
                },
                type: ButtonType.text,
                size: ButtonSize.medium,
                isFullWidth: true,
                color: AppColors.error,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(ProfileModel profile) {
    return Column(
      children: [
        // Profile Image
        Stack(
          children: [
            ProfileImage(
              imageUrl: profile.photos.isNotEmpty ? profile.photos.first : null,
              radius: 50,
              isVerified: profile.isVerified,
            ),
            if (profile.isOnline)
              const Positioned(
                bottom: 5,
                right: 5,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: AppColors.success,
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Name and Age
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (profile.age != null) ...[
              const SizedBox(width: 8),
              Text(
                '• ${profile.age}',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),

        if (profile.location != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                profile.location!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            value: profile.followers.toString(),
            label: 'Followers',
            icon: Icons.people_outline,
          ),
          Container(
            height: 30,
            width: 1,
            color: AppColors.divider,
          ),
          _buildStatItem(
            value: profile.following.toString(),
            label: 'Following',
            icon: Icons.person_add_outlined,
          ),
          Container(
            height: 30,
            width: 1,
            color: AppColors.divider,
          ),
          _buildStatItem(
            value: profile.matches.toString(),
            label: 'Matches',
            icon: Icons.favorite_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection(ProfileModel profile) {
    if (profile.bio == null || profile.bio!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.aboutMe,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'သင့်အကြောင်း ထည့်သွင်းရန် ပရိုဖိုင်ကို ပြင်ဆင်ပါ',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.aboutMe,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.bio!,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.myPhotos,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all photos
                },
                child: const Text('အားလုံးကြည့်ရန်'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (profile.photos.isEmpty)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'ဓာတ်ပုံများ မရှိသေးပါ',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: profile.photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(profile.photos[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(ProfileModel profile) {
    if (profile.interests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.interests,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'စိတ်ဝင်စားမှုများ ထည့်သွင်းရန် ပရိုဖိုင်ကို ပြင်ဆင်ပါ',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.interests,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interest,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.basicInfo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.work_outline,
            label: 'အလုပ်အကိုင်',
            value: profile.occupation ?? 'မထည့်သွင်းရသေး',
          ),
          const Divider(height: 16),
          _buildInfoRow(
            icon: Icons.school_outlined,
            label: 'ပညာအရည်အချင်း',
            value: profile.education ?? 'မထည့်သွင်းရသေး',
          ),
          const Divider(height: 16),
          _buildInfoRow(
            icon: Icons.wc_outlined,
            label: 'လိင်',
            value: profile.gender ?? 'မထည့်သွင်းရသေး',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'ပရိုဖိုင်ကို ရယူရန် မအောင်မြင်ပါ',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'ပြန်ကြိုးစားမည်',
            onPressed: profileController.loadProfile,
            type: ButtonType.primary,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('ထွက်မည်'),
        content: const Text('အကောင့်မှ ထွက်ရန် သေချာပါသလား?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('မလုပ်တော့ပါ'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<AuthController>().signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('ထွက်မည်'),
          ),
        ],
      ),
    );
  }
}