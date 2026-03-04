import 'package:get/get.dart';
import '../../data/models/profile_model.dart';

class ProfileController extends GetxController {
  final profile = Rxn<ProfileModel>();
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Mock profile data
      profile.value = ProfileModel(
        id: '1',
        displayName: 'User Name',
        bio: 'This is a test bio',
        age: 25,
        gender: 'အမျိုးသား',
        location: 'ရန်ကုန်',
        photos: [],
        interests: ['ခရီးသွား', 'စာအဖတ်'],
        followers: 10,
        following: 5,
        matches: 3,
        isVerified: true,
        isOnline: true,
        lastActive: DateTime.now(),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> uploadImage(dynamic image) async {
    // TODO: Implement image upload
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/uploaded_image.jpg';
  }

  Future<bool> updateProfile(ProfileModel updatedProfile) async {
    try {
      isSaving.value = true;
      await Future.delayed(const Duration(seconds: 1));
      profile.value = updatedProfile;
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}