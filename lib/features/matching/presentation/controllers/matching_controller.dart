import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/data/models/profile_model.dart';

class MatchingController extends GetxController {
  // Loading states
  final isLoading = false.obs;
  final isLoadingLikes = false.obs;
  final isLoadingMatches = false.obs;

  // Data lists
  final profiles = <ProfileModel>[].obs;
  final likes = <Map<String, dynamic>>[].obs;
  final matches = <Map<String, dynamic>>[].obs;

  // Current index
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfiles();
    loadLikes();
    loadMatches();
  }

  // Load profiles for discovery
  Future<void> loadProfiles() async {
    try {
      isLoading.value = true;

      // TODO: Implement API call to get profiles
      // This is mock data for now
      await Future.delayed(const Duration(seconds: 1));

      profiles.value = [
        ProfileModel(
          id: '1',
          displayName: 'စုစုလေး',
          bio: 'ခရီးသွားရတာ ကြိုက်တယ်။ စာအဖတ်ဝါသနာပါတယ်။',
          age: 25,
          gender: 'အမျိုးသမီး',
          location: 'ရန်ကုန်',
          photos: ['https://example.com/photo1.jpg'],
          interests: ['ခရီးသွား', 'စာအဖတ်', 'ဂီတ'],
          isVerified: true,
          lastActive: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        ProfileModel(
          id: '2',
          displayName: 'မောင်မောင်',
          bio: 'ကော်ဖီဆိုင်သွားရတာ ကြိုက်တယ်။ တောင်တက်ဝါသနာပါတယ်။',
          age: 28,
          gender: 'အမျိုးသား',
          location: 'မန္တလေး',
          photos: ['https://example.com/photo2.jpg'],
          interests: ['ကော်ဖီ', 'တောင်တက်', 'ဓာတ်ပုံ'],
          isVerified: false,
          lastActive: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      Get.snackbar('အမှား', 'ပရိုဖိုင်များ ရယူရန် မအောင်မြင်ပါ');
    } finally {
      isLoading.value = false;
    }
  }

  // Load users who liked current user
  Future<void> loadLikes() async {
    try {
      isLoadingLikes.value = true;

      // TODO: Implement API call to get likes
      await Future.delayed(const Duration(seconds: 1));

      likes.value = [
        {
          'id': '101',
          'displayName': 'အိအိလေး',
          'age': 24,
          'location': 'ရန်ကုန်',
          'photoUrl': 'https://example.com/like1.jpg',
        },
        {
          'id': '102',
          'displayName': 'ဖြိုးဖြိုး',
          'age': 26,
          'location': 'မန္တလေး',
          'photoUrl': 'https://example.com/like2.jpg',
        },
      ];
    } catch (e) {
      Get.snackbar('အမှား', 'စိတ်ဝင်စားမှုများ ရယူရန် မအောင်မြင်ပါ');
    } finally {
      isLoadingLikes.value = false;
    }
  }

  // Load matches
  Future<void> loadMatches() async {
    try {
      isLoadingMatches.value = true;

      // TODO: Implement API call to get matches
      await Future.delayed(const Duration(seconds: 1));

      matches.value = [
        {
          'id': '201',
          'displayName': 'သွန်းသွန်း',
          'photoUrl': 'https://example.com/match1.jpg',
          'isOnline': true,
          'lastActive': DateTime.now(),
        },
        {
          'id': '202',
          'displayName': 'နေနေ',
          'photoUrl': 'https://example.com/match2.jpg',
          'isOnline': false,
          'lastActive': DateTime.now().subtract(const Duration(hours: 2)),
        },
      ];
    } catch (e) {
      Get.snackbar('အမှား', 'ကိုက်ညီမှုများ ရယူရန် မအောင်မြင်ပါ');
    } finally {
      isLoadingMatches.value = false;
    }
  }

  // Like profile
  Future<void> likeProfile(String profileId) async {
    try {
      // TODO: Implement API call to like profile
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from list
      profiles.removeWhere((p) => p.id == profileId);

      // Check if it's a match
      final isMatch = await _checkForMatch(profileId);
      if (isMatch) {
        _showMatchNotification(profileId);
      }

    } catch (e) {
      Get.snackbar('အမှား', 'စိတ်ဝင်စားမှု ပေးပို့ရန် မအောင်မြင်ပါ');
    }
  }

  // Super like profile
  Future<void> superLikeProfile(String profileId) async {
    try {
      // TODO: Implement API call to super like profile
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from list
      profiles.removeWhere((p) => p.id == profileId);

      Get.snackbar(
        'အထူးစိတ်ဝင်စားမှု',
        'ပေးပို့ပြီးပါပြီ',
        backgroundColor: AppColors.primary.withOpacity(0.1),
        colorText: AppColors.primary,
      );

    } catch (e) {
      Get.snackbar('အမှား', 'အထူးစိတ်ဝင်စားမှု ပေးပို့ရန် မအောင်မြင်ပါ');
    }
  }

  // Pass profile
  Future<void> passProfile(String profileId) async {
    try {
      // TODO: Implement API call to pass profile
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from list
      profiles.removeWhere((p) => p.id == profileId);

    } catch (e) {
      Get.snackbar('အမှား', 'ကျော်သွားရန် မအောင်မြင်ပါ');
    }
  }

  // Accept like
  Future<void> acceptLike(String likeId) async {
    try {
      // TODO: Implement API call to accept like
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from likes
      likes.removeWhere((l) => l['id'] == likeId);

      // Add to matches
      final like = likes.firstWhere((l) => l['id'] == likeId);
      matches.add({
        'id': like['id'],
        'displayName': like['displayName'],
        'photoUrl': like['photoUrl'],
        'isOnline': true,
        'lastActive': DateTime.now(),
      });

    } catch (e) {
      Get.snackbar('အမှား', 'လက်ခံရန် မအောင်မြင်ပါ');
    }
  }

  // Reject like
  Future<void> rejectLike(String likeId) async {
    try {
      // TODO: Implement API call to reject like
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from likes
      likes.removeWhere((l) => l['id'] == likeId);

    } catch (e) {
      Get.snackbar('အမှား', 'ပယ်ဖျက်ရန် မအောင်မြင်ပါ');
    }
  }

  // Check if it's a match
  Future<bool> _checkForMatch(String profileId) async {
    // TODO: Implement API call to check match
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Mock: always return true
  }

  // Show match notification
  void _showMatchNotification(String profileId) {
    // Show dialog or snackbar
    Get.snackbar(
      'It\'s a Match!',
      'သင်နှင့် ဤသူသည် တစ်ဦးကိုတစ်ဦး စိတ်ဝင်စားကြသည်',
      backgroundColor: AppColors.success.withOpacity(0.1),
      colorText: AppColors.success,
      duration: const Duration(seconds: 3),
    );
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadProfiles(),
      loadLikes(),
      loadMatches(),
    ]);
  }
}