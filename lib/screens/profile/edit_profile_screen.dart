import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/data/models/user_model.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/widgets/custom_button.dart';
import 'package:them_dating_app/widgets/custom_textfield.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();

  String? _selectedGender;
  String? _selectedLookingFor;
  List<File> _selectedImages = [];
  List<String> _selectedInterests = [];

  final ImagePicker _picker = ImagePicker();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _lookingForOptions = ['Male', 'Female', 'Everyone'];
  final List<String> _availableInterests = [
    'Travel', 'Music', 'Photography', 'Food', 'Sports',
    'Movies', 'Books', 'Art', 'Fitness', 'Gaming',
    'Dancing', 'Cooking', 'Hiking', 'Yoga', 'Meditation',
    'Coffee', 'Pets', 'Fashion', 'Tech', 'Nature'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        _nameController.text = user.name ?? '';
        _bioController.text = user.bio ?? '';
        _ageController.text = user.age?.toString() ?? '';
        _phoneController.text = user.phoneNumber ?? '';
        _selectedGender = user.gender;
        _selectedLookingFor = user.lookingFor;
        _selectedInterests = List.from(user.interests);
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      _cropImage(File(image.path));
    }
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: 'Edit Photo',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        if (_selectedImages.length < 6) {
          _selectedImages.add(File(croppedFile.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 6 photos allowed'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      _cropImage(File(image.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library, color: AppColors.primary),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length < 10) {
          _selectedInterests.add(interest);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 10 interests allowed'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) return;

      // TODO: Upload images to Firebase Storage
      final List<String> photoUrls = [];

      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        bio: _bioController.text,
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
        lookingFor: _selectedLookingFor,
        phoneNumber: _phoneController.text,
        interests: _selectedInterests,
        photos: photoUrls,
      );

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );

      await authProvider.updateUserProfile(updatedUser, context);

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Go back
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Photos Grid
                  _buildPhotosGrid(),
                  const SizedBox(height: 24),

                  // Progress Indicator
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),

                  // Basic Info
                  _buildBasicInfo(),
                  const SizedBox(height: 24),

                  // Interests
                  _buildInterestsSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalFields = 6; // Name, Age, Gender, LookingFor, Bio, Interests
    final filledFields = [
      _nameController.text.isNotEmpty,
      _ageController.text.isNotEmpty,
      _selectedGender != null,
      _selectedLookingFor != null,
      _bioController.text.isNotEmpty,
      _selectedInterests.isNotEmpty,
    ].where((filled) => filled).length;

    final progress = filledFields / totalFields;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                'Profile Completion',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Photos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_selectedImages.length}/6',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedImages.length) {
              return GestureDetector(
                onTap: _selectedImages.length < 6 ? _showImageSourceDialog : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: FileImage(_selectedImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: 12,
                      ),
                    ),
                  ),
                ),
                if (index == 0)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Main',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (_selectedImages.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Add up to 6 photos to showcase your personality',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400], size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Age and Gender Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: '25',
                    prefixIcon: Icon(Icons.cake, color: Colors.grey[400], size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Gender',
                    ),
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Looking For
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedLookingFor,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: 'Looking For',
                prefixIcon: Icon(Icons.favorite_border, size: 20),
              ),
              items: _lookingForOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLookingFor = value;
                });
              },
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
            ),
          ),

          const SizedBox(height: 16),

          // Phone (Optional)
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number (Optional)',
              hintText: '+1 234 567 890',
              prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[400], size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          // Location
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              hintText: 'New York, USA',
              prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[400], size: 20),
              suffixIcon: IconButton(
                icon: Icon(Icons.my_location, color: AppColors.primary, size: 20),
                onPressed: () {
                  // Get current location
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 16),

          // Occupation
          TextFormField(
            controller: _occupationController,
            decoration: InputDecoration(
              labelText: 'Occupation',
              hintText: 'Software Developer',
              prefixIcon: Icon(Icons.work_outline, color: Colors.grey[400], size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 16),

          // Bio
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'About Me',
              hintText: 'Tell us about yourself, your interests, and what makes you unique...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.interests, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${_selectedInterests.length}/10',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (_) => _toggleInterest(interest),
                backgroundColor: Colors.grey[50],
                selectedColor: AppColors.primary.withOpacity(0.1),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedInterests.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Select your interests to help find better matches',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    super.dispose();
  }
}