import 'package:get/get.dart';

import '../data/models/chat_room_model.dart';
import '../data/models/message_model.dart';

class ChatController extends GetxController {
  final chatRooms = <ChatRoomModel>[].obs;
  final messages = <MessageModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMessages = false.obs;
  final isTyping = false.obs;
  final totalUnreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadChatRooms();
  }

  Future<void> loadChatRooms() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      // TODO: Implement actual API call
    } catch (e) {
      print('Error loading chat rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(String roomId) async {
    try {
      isLoadingMessages.value = true;
      await Future.delayed(const Duration(seconds: 1));
      // TODO: Implement actual API call
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void joinRoom(String roomId) {
    // TODO: Implement join room
  }

  void leaveRoom(String roomId) {
    // TODO: Implement leave room
  }

  void sendMessage(String roomId, String content) {
    // TODO: Implement send message
  }

  void sendImage(String roomId, dynamic image) {
    // TODO: Implement send image
  }

  void sendTypingStatus(String roomId, bool isTyping) {
    this.isTyping.value = isTyping;
    // TODO: Implement send typing status
  }

  void muteNotifications(String roomId) {
    // TODO: Implement mute notifications
  }

  void blockUser(String roomId) {
    // TODO: Implement block user
  }

  void reportUser(String roomId, String reason) {
    // TODO: Implement report user
  }
}