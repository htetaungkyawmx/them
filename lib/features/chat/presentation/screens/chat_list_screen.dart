import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/profile_image.dart';
import '../../../core/themes/app_theme.dart';
import '../controllers/chat_controller.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.messages),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search chats
            },
          ),
        ],
      ),
      body: Obx(() {
        if (chatController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (chatController.chatRooms.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chatController.chatRooms.length,
          itemBuilder: (context, index) {
            final room = chatController.chatRooms[index];
            return _buildChatItem(room);
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
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 70,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'စာတိုများ မရှိသေးပါ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'သင့်နဲ့ ကိုက်ညီသူတွေကို စတင်ရှာဖွေပါ',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'ရှာဖွေမည်',
            onPressed: () {
              Get.toNamed('/matching');
            },
            type: ButtonType.primary,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatRoomModel room) {
    final participant = room.participants.values.first;
    final isOnline = participant['isOnline'] ?? false;
    final lastMessage = room.lastMessage;

    return InkWell(
      onTap: () {
        Get.to(() => ChatScreen(room: room));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
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
        child: Row(
          children: [
            // Profile Image
            ProfileImage(
              imageUrl: participant['photoUrl'],
              radius: 28,
              isOnline: isOnline,
            ),

            const SizedBox(width: 12),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          participant['displayName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (lastMessage != null)
                        Text(
                          _formatTime(lastMessage.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage?.content ?? 'စတင်စကားပြောရန်...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: lastMessage?.isMe ?? false
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontWeight: lastMessage?.isMe ?? true
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (room.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            room.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
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

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}