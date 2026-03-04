import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('စာရင်းသွင်းရန်'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Step Indicator
              _buildStepIndicator(),

              const SizedBox(height: 30),

              // Form
              Expanded(
                child: _buildCurrentStep(),
              ),

              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? AppColors.primary
                  : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildProfileInfoStep();
      case 2:
        return _buildInterestsStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'အမည်',
            hintText: 'သင့်အမည် ထည့်သွင်းပါ',
            controller: nameController,
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ကျေးဇူးပြု၍ အမည် ထည့်သွင်းပါ';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          CustomTextField(
            label: AppStrings.email,
            hintText: 'example@gmail.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ကျေးဇူးပြု၍ အီးမေးလ် ထည့်သွင်းပါ';
              }
              if (!GetUtils.isEmail(value)) {
                return 'မှန်ကန်သော အီးမေးလ် ထည့်သွင်းပါ';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          CustomTextField(
            label: AppStrings.password,
            controller: passwordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ကျေးဇူးပြု၍ စကားဝှက် ထည့်သွင်းပါ';
              }
              if (value.length < 6) {
                return 'စကားဝှက်သည် အနည်းဆုံး ၆ လုံးရှိရပါမည်';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          CustomTextField(
            label: AppStrings.confirmPassword,
            controller: confirmPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ကျေးဇူးပြု၍ စကားဝှက် အတည်ပြုပါ';
              }
              if (value != passwordController.text) {
                return 'စကားဝှက် မတူညီပါ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoStep() {
    return Column(
      children: [
        // Profile Image Upload
        GestureDetector(
          onTap: () {
            // Pick image
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const CircleAvatar(
              radius: 58,
              backgroundColor: AppColors.surfaceDark,
              child: Icon(
                Icons.camera_alt,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Age & Gender
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'အသက်',
                value: '၂၅',
                items: List.generate(50, (index) => (index + 18).toString()),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                label: 'လိင်',
                value: 'အမျိုးသား',
                items: ['အမျိုးသား', 'အမျိုးသမီး', 'အခြား'],
                onChanged: (value) {},
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Location
        CustomTextField(
          label: AppStrings.location,
          hintText: 'သင်နေထိုင်ရာမြို့',
          prefixIcon: Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _buildInterestsStep() {
    final interests = [
      'ခရီးသွား',
      'စာအဖတ်',
      'ဂီတ',
      'ရုပ်ရှင်',
      'အားကစား',
      'ဓာတ်ပုံ',
      'ချက်ပြုတ်',
      'ယောဂ',
      'အကများ',
      'ကော်ဖီ',
      'တောင်တက်',
      'ရေကူး',
    ];

    return Column(
      children: [
        const Text(
          'သင့်စိတ်ဝင်စားမှုများကို ရွေးချယ်ပါ (အနည်းဆုံး ၃ ခု)',
          style: TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 20),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: interests.map((interest) {
            return FilterChip(
              label: Text(interest),
              selected: false,
              onSelected: (selected) {},
              backgroundColor: AppColors.surfaceDark,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: const TextStyle(
                color: AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: CustomButton(
              text: 'နောက်သို့',
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              type: ButtonType.outline,
              size: ButtonSize.medium,
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _currentStep == 2 ? 'ပြီးဆုံး' : 'ရှေ့သို့',
            onPressed: () {
              if (_currentStep < 2) {
                setState(() {
                  _currentStep++;
                });
              } else {
                // Complete signup
              }
            },
            type: ButtonType.primary,
            size: ButtonSize.medium,
          ),
        ),
      ],
    );
  }
}