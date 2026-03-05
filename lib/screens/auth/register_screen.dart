import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:them_dating_app/config/routes.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/data/models/user_model.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/widgets/custom_button.dart';
import 'package:them_dating_app/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  final String? phoneNumber;
  const RegisterScreen({super.key, this.phoneNumber});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedGender;
  String? _selectedLookingFor;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _lookingForOptions = ['Male', 'Female', 'Everyone'];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one photo'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = UserModel(
        id: authProvider.currentUser?.id ?? '',
        phoneNumber: widget.phoneNumber ?? '',
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
        lookingFor: _selectedLookingFor,
        bio: _bioController.text,
        photos: [], // You'll upload images to Firebase Storage first
        interests: [],
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      // TODO: Upload images to Firebase Storage
      // Then save user data
      await authProvider.registerUser(user);

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos Section
              Text(
                'Add Photos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add at least 1 photo to get started',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Photo Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textSecondary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Add',
                              style: TextStyle(color: AppColors.textSecondary),
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
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Basic Info Section
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefix: const Icon(Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: _ageController,
                label: 'Age',
                prefix: const Icon(Icons.cake),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 18) {
                    return 'You must be at least 18 years old';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.transgender),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Looking For Dropdown
              DropdownButtonFormField<String>(
                value: _selectedLookingFor,
                decoration: InputDecoration(
                  labelText: 'Looking For',
                  prefixIcon: const Icon(Icons.favorite),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                validator: (value) {
                  if (value == null) {
                    return 'Please select what you\'re looking for';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: 'About Me',
                  hintText: 'Tell us a little about yourself...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Register Button
              Consumer<AuthProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Create Profile',
                    onPressed: _handleRegister,
                    isLoading: provider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}