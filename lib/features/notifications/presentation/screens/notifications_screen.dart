import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/profile_image.dart';
import '../../../core/themes/app_theme.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final NotificationsController controller = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('အကြောင်းကြားချက်များ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_outlined),
            onPressed: controller.markAllAsRead,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationItem(notification);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'အကြောင်းကြားချက်များ မရှိသေးပါ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'သင်နှင့် ပတ်သက်သော အကြောင်းကြားချက်များ ဤနေရာတွင် ပေါ်လာပါမည်',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.like:
        iconData = Icons.favorite;
        iconColor = AppColors.primary;
        break;
      case NotificationType.match:
        iconData = Icons.people;
        iconColor = AppColors.success;
        break;
      case NotificationType.message:
        iconData = Icons.chat_bubble_outline;
        iconColor = AppColors.info;
        break;
      case NotificationType.superLike:
        iconData = Icons.star;
        iconColor = AppColors.warning;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.textSecondary;
    }

    return InkWell(
      onTap: () {
        controller.markAsRead(notification.id);
        // Handle navigation based on type
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Time
            Text(
              _formatTime(notification.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'အခုလေးတင်';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} မိနစ်က';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} နာရီက';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ရက်က';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}