import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final RxBool isDarkMode = false.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxDouble searchRadius = 50.0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ဆက်တင်များ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Settings
          _buildSection(
            title: 'အကောင့်ဆက်တင်များ',
            children: [
              _buildSettingItem(
                icon: Icons.person_outline,
                title: 'ကိုယ်ရေးအချက်အလက်',
                onTap: () {
                  // Navigate to personal info
                },
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'လုံခြုံရေး',
                onTap: () {
                  // Navigate to security
                },
              ),
              _buildSettingItem(
                icon: Icons.verified_user_outlined,
                title: 'အကောင့် အတည်ပြုခြင်း',
                onTap: () {
                  // Navigate to verification
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Privacy Settings
          _buildSection(
            title: 'ကိုယ်ရေးလုံခြုံမှု',
            children: [
              _buildSwitchItem(
                icon: Icons.notifications_outlined,
                title: 'အကြောင်းကြားချက်များ',
                value: notificationsEnabled,
                onChanged: (value) {
                  notificationsEnabled.value = value;
                },
              ),
              _buildSettingItem(
                icon: Icons.visibility_outlined,
                title: 'ပရိုဖိုင် မြင်နိုင်သူများ',
                onTap: () {
                  // Navigate to visibility
                },
              ),
              _buildSettingItem(
                icon: Icons.block_outlined,
                title: 'ပိတ်ပင်ထားသူများ',
                onTap: () {
                  // Navigate to blocked users
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Discovery Settings
          _buildSection(
            title: 'ရှာဖွေမှု ဆက်တင်များ',
            children: [
              _buildSettingItem(
                icon: Icons.location_on_outlined,
                title: 'တည်နေရာ',
                value: 'ရန်ကုန်',
                onTap: () {
                  // Change location
                },
              ),
              _buildSliderItem(
                icon: Icons.radar_outlined,
                title: 'ရှာဖွေမှု အကွာအဝေး',
                value: searchRadius,
                min: 1,
                max: 100,
                unit: 'km',
              ),
              _buildSettingItem(
                icon: Icons.filter_list_outlined,
                title: 'ဦးစားပေး စစ်ထုတ်မှုများ',
                onTap: () {
                  // Navigate to preferences
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Appearance
          _buildSection(
            title: 'အသွင်အပြင်',
            children: [
              _buildSwitchItem(
                icon: Icons.dark_mode_outlined,
                title: 'အမှောင်မုဒ်',
                value: isDarkMode,
                onChanged: (value) {
                  isDarkMode.value = value;
                  // Toggle theme
                },
              ),
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: 'ဘာသာစကား',
                value: 'မြန်မာ',
                onTap: () {
                  // Change language
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Support
          _buildSection(
            title: 'အကူအညီ',
            children: [
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'အကူအညီ',
                onTap: () {
                  // Navigate to help
                },
              ),
              _buildSettingItem(
                icon: Icons.feedback_outlined,
                title: 'အကြံပြုချက်',
                onTap: () {
                  // Navigate to feedback
                },
              ),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: 'အက်ပ်အကြောင်း',
                value: 'ဗားရှင်း 1.0.0',
                onTap: () {
                  // Navigate to about
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Danger Zone
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _buildDangerItem(
                  icon: Icons.delete_outline,
                  title: 'အကောင့် ဖျက်ရန်',
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(() => ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: Switch(
        value: value.value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    ));
  }

  Widget _buildSliderItem({
    required IconData icon,
    required String title,
    required RxDouble value,
    required double min,
    required double max,
    required String unit,
  }) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: value.value,
                        min: min,
                        max: max,
                        divisions: 100,
                        onChanged: (newValue) {
                          value.value = newValue;
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${value.value.round()}$unit',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildDangerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(
        title,
        style: const TextStyle(color: Colors.red),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.red),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('အကောင့် ဖျက်ရန်'),
        content: const Text(
          'သင့်အကောင့်ကို ဖျက်ပါက ဒေတာများ အားလုံး ဆုံးရှုံးသွားမည်ဖြစ်ပြီး ပြန်လည်ရယူ၍ မရနိုင်ပါ။ ဆက်လက်ဆောင်ရွက်ရန် သေချာပါသလား?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('မလုပ်တော့ပါ'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Delete account
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('ဖျက်မည်'),
          ),
        ],
      ),
    );
  }
}