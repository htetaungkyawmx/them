import 'package:get/get.dart';
import '../data/models/notification_model.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;

      // TODO: Implement API call to load notifications
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      notifications.value = [
        NotificationModel(
          id: '1',
          userId: 'user1',
          type: NotificationType.like,
          title: 'စိတ်ဝင်စားမှုအသစ်',
          body: 'စုစုလေးက သင့်ကို စိတ်ဝင်စားပါတယ်',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        NotificationModel(
          id: '2',
          userId: 'user1',
          type: NotificationType.match,
          title: 'It\'s a Match!',
          body: 'သင်နှင့် မောင်မောင် တစ်ဦးကိုတစ်ဦး စိတ်ဝင်စားကြသည်',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        NotificationModel(
          id: '3',
          userId: 'user1',
          type: NotificationType.message,
          title: 'မက်ဆေ့ချ်အသစ်',
          body: 'အိအိလေးက မင်္ဂလာပါလို့ ပို့ထားပါတယ်',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];

      _updateUnreadCount();

    } catch (e) {
      Get.snackbar('အမှား', 'အကြောင်းကြားချက်များ ရယူရန် မအောင်မြင်ပါ');
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = notifications[index];
      notifications[index] = notification.copyWith(isRead: true);
      _updateUnreadCount();

      // TODO: Implement API call to mark as read
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();

    // TODO: Implement API call to mark all as read
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Listen for new notifications (via WebSocket)
  void onNewNotification(NotificationModel notification) {
    notifications.insert(0, notification);
    _updateUnreadCount();
  }
}