import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/themes/app_theme.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController profileController;
  late final TextEditingController nameController;
  late final TextEditingController bioController;
  late final TextEditingController occupationController;
  late final TextEditingController educationController;
  late final TextEditingController locationController;

  String? selectedGender;
  int? selectedAge;
  List<String> selectedInterests = [];
  List<File> newImages = [];
  List<String> existingPhotos = [];

  final ImagePicker _imagePicker = ImagePicker();

  final List<String> availableInterests = [
    'ခရီးသွား', 'စာအဖတ်', 'ဂီတ', 'ရုပ်ရှင်', 'အားကစား',
    'ဓာတ်ပုံ', 'ချက်ပြုတ်', 'ယောဂ', 'အကများ', 'ကော်ဖီ',
    'တောင်တက်', 'ရေကူး', 'စက်ဘီးစီး', 'ဥယျာဉ်စိုက်', 'တိရစ္ဆာန်',
    'နည်းပညာ', 'ဂိမ်း', 'ပန်းချီ', 'စာရေး', 'စေတနာ့ဝန်ထမ်း'
  ];

  @override
  void initState() {
    super.initState();
    profileController = Get.find<ProfileController>();

    // Initialize controllers with existing data
    nameController = TextEditingController(text: widget.profile.displayName);
    bioController = TextEditingController(text: widget.profile.bio ?? '');
    occupationController = TextEditingController(text: widget.profile.occupation ?? '');
    educationController = TextEditingController(text: widget.profile.education ?? '');
    locationController = TextEditingController(text: widget.profile.location ?? '');

    selectedGender = widget.profile.gender;
    selectedAge = widget.profile.age;
    selectedInterests = List.from(widget.profile.interests);
    existingPhotos = List.from(widget.profile.photos);
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    occupationController.dispose();
    educationController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပရိုဖိုင် ပြင်ဆင်ရန်'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'သိမ်းမည်',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isSaving.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos Section
              _buildPhotosSection(),

              const SizedBox(height: 24),

              // Basic Info Section
              _buildBasicInfoSection(),

              const SizedBox(height: 24),

              // Bio Section
              CustomTextField(
                label: AppStrings.aboutMe,
                controller: bioController,
                maxLines: 4,
                hintText: 'သင့်အကြောင်း ရေးသားပါ...',
              ),

              const SizedBox(height: 24),

              // Interests Section
              _buildInterestsSection(),

              const SizedBox(height: 24),

              // Work & Education
              _buildWorkEducationSection(),

              const SizedBox(height: 24),

              // Location
              CustomTextField(
                label: AppStrings.location,
                controller: locationController,
                prefixIcon: Icons.location_on_outlined,
                hintText: 'သင်နေထိုင်ရာမြို့',
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ဓာတ်ပုံများ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Existing photos
              ...existingPhotos.map((photoUrl) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            existingPhotos.remove(photoUrl);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // New images
              ...newImages.map((file) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            newImages.remove(file);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // Add button
              if (existingPhotos.length + newImages.length < 6)
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ဓာတ်ပုံထည့်',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'အခြေခံ အချက်အလက်',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Name
        CustomTextField(
          label: 'အမည်',
          controller: nameController,
          prefixIcon: Icons.person_outline,
        ),

        const SizedBox(height: 16),

        // Age and Gender Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'အသက်',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedAge,
                        hint: const Text('ရွေးချယ်ပါ'),
                        isExpanded: true,
                        items: List.generate(63, (index) {
                          final age = index + 18;
                          return DropdownMenuItem(
                            value: age,
                            child: Text(age.toString()),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            selectedAge = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'လိင်',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedGender,
                        hint: const Text('ရွေးချယ်ပါ'),
                        isExpanded: true,
                        items: ['အမျိုးသား', 'အမျိုးသမီး', 'အခြား']
                            .map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
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
          children: availableInterests.map((interest) {
            final isSelected = selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (selectedInterests.length < 10) {
                      selectedInterests.add(interest);
                    }
                  } else {
                    selectedInterests.remove(interest);
                  }
                });
              },
              backgroundColor: AppColors.surfaceDark,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
        if (selectedInterests.length >= 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'အများဆုံး ၁၀ ခုသာ ရွေးချယ်နိုင်ပါသည်',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warning,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWorkEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'အလုပ်နှင့် ပညာရေး',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Occupation
        CustomTextField(
          label: AppStrings.occupation,
          controller: occupationController,
          prefixIcon: Icons.work_outline,
          hintText: 'ဥပမာ - ဆရာဝန်',
        ),

        const SizedBox(height: 16),

        // Education
        CustomTextField(
          label: AppStrings.education,
          controller: educationController,
          prefixIcon: Icons.school_outlined,
          hintText: 'ဥပမာ - တက္ကသိုလ်',
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          newImages.add(File(image.path));
        });
      }
    } catch (e) {
      Get.snackbar(
        'အမှား',
        'ဓာတ်ပုံ ရွေးချယ်ရန် မအောင်မြင်ပါ',
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  void _saveProfile() async {
    // Validate
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'သတိပေးချက်',
        'ကျေးဇူးပြု၍ အမည် ထည့်သွင်းပါ',
        backgroundColor: AppColors.warning.withOpacity(0.1),
        colorText: AppColors.warning,
      );
      return;
    }

    // Show loading
    profileController.isSaving.value = true;

    // Upload new images
    List<String> allPhotos = List.from(existingPhotos);

    for (var image in newImages) {
      // Upload image to Firebase Storage
      String? imageUrl = await profileController.uploadImage(image);
      if (imageUrl != null) {
        allPhotos.add(imageUrl);
      }
    }

    // Update profile
    final updatedProfile = widget.profile.copyWith(
      displayName: nameController.text.trim(),
      bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
      age: selectedAge,
      gender: selectedGender,
      occupation: occupationController.text.trim().isEmpty
          ? null
          : occupationController.text.trim(),
      education: educationController.text.trim().isEmpty
          ? null
          : educationController.text.trim(),
      location: locationController.text.trim().isEmpty
          ? null
          : locationController.text.trim(),
      photos: allPhotos,
      interests: selectedInterests,
    );

    bool success = await profileController.updateProfile(updatedProfile);

    if (success) {
      Get.back();
      Get.snackbar(
        'အောင်မြင်သည်',
        'ပရိုဖိုင် ပြင်ဆင်ပြီးပါပြီ',
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
    }
  }
}