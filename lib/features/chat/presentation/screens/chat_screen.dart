import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widgets/profile_image.dart';
import '../../../core/themes/app_theme.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoomModel room;

  const ChatScreen({super.key, required this.room});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController chatController;
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  final ImagePicker imagePicker = ImagePicker();

  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    chatController.joinRoom(widget.room.id);
    chatController.loadMessages(widget.room.id);

    // Scroll to bottom when new message arrives
    chatController.messages.listen((messages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    chatController.leaveRoom(widget.room.id);
    super.dispose();
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    chatController.sendMessage(
      widget.room.id,
      messageController.text.trim(),
    );

    messageController.clear();
  }

  Future<void> _pickImage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      chatController.sendImage(
        widget.room.id,
        File(image.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.room.participants.values.first;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            ProfileImage(
              imageUrl: participant['photoUrl'],
              radius: 20,
              isOnline: participant['isOnline'] ?? false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant['displayName'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Obx(() => Text(
                    chatController.isTyping.value
                        ? AppStrings.typing
                        : (participant['isOnline'] ?? false
                        ? AppStrings.online
                        : AppStrings.offline),
                    style: TextStyle(
                      fontSize: 12,
                      color: chatController.isTyping.value
                          ? AppColors.primary
                          : (participant['isOnline'] ?? false
                          ? AppColors.success
                          : AppColors.textSecondary),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              if (chatController.isLoadingMessages.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  return MessageBubble(message: message);
                },
              );
            }),
          ),

          // Typing Indicator
          Obx(() => chatController.isTyping.value
              ? const TypingIndicator()
              : const SizedBox.shrink()),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attach Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: _showAttachmentOptions,
            ),
          ),

          const SizedBox(width: 8),

          // Text Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      focusNode: focusNode,
                      onChanged: (text) {
                        if (text.isNotEmpty && !isTyping) {
                          setState(() => isTyping = true);
                          chatController.sendTypingStatus(widget.room.id, true);
                        } else if (text.isEmpty && isTyping) {
                          setState(() => isTyping = false);
                          chatController.sendTypingStatus(widget.room.id, false);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: AppStrings.typeMessage,
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                  if (messageController.text.isEmpty)
                    IconButton(
                      icon: const Icon(Icons.photo, color: AppColors.primary),
                      onPressed: _pickImage,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ဖိုင်တွဲရန်',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentItem(
                      icon: Icons.photo,
                      label: 'ဓာတ်ပုံ',
                      color: Colors.blue,
                      onTap: _pickImage,
                    ),
                    _buildAttachmentItem(
                      icon: Icons.videocam,
                      label: 'ဗီဒီယို',
                      color: Colors.green,
                      onTap: () {},
                    ),
                    _buildAttachmentItem(
                      icon: Icons.mic,
                      label: 'အသံ',
                      color: Colors.orange,
                      onTap: () {},
                    ),
                    _buildAttachmentItem(
                      icon: Icons.location_on,
                      label: 'တည်နေရာ',
                      color: Colors.red,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ချက်တင် ရွေးချယ်စရာများ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionItem(
                  icon: Icons.person,
                  label: 'ပရိုဖိုင်ကြည့်ရန်',
                  onTap: () {
                    Get.back();
                    // View profile
                  },
                ),
                _buildOptionItem(
                  icon: Icons.notifications_off,
                  label: 'အကြောင်းကြားချက် ပိတ်ရန်',
                  onTap: () {
                    Get.back();
                    chatController.muteNotifications(widget.room.id);
                  },
                ),
                _buildOptionItem(
                  icon: Icons.block,
                  label: 'ပိတ်ပင်ရန်',
                  color: Colors.red,
                  onTap: () {
                    Get.back();
                    _showBlockConfirmation();
                  },
                ),
                _buildOptionItem(
                  icon: Icons.report,
                  label: 'သတင်းပို့ရန်',
                  color: Colors.red,
                  onTap: () {
                    Get.back();
                    _showReportDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }

  void _showBlockConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('ပိတ်ပင်ရန် သေချာပါသလား?'),
        content: const Text(
          'ဤအသုံးပြုသူကို ပိတ်ပင်ပါက သူပို့သော မက်ဆေ့ခ်ျများကို လက်ခံရရှိမည် မဟုတ်ပါ။',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('မလုပ်တော့ပါ'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              chatController.blockUser(widget.room.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('ပိတ်ပင်မည်'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    final reportReasons = [
      'မလိုလားအပ်သော မက်ဆေ့ခ်ျများ',
      'နှောင့်ယှက်ခြင်း',
      'အတုအယောင် အကောင့်',
      'လိင်ပိုင်းဆိုင်ရာ နှောင့်ယှက်ခြင်း',
      'အခြား',
    ];

    Get.dialog(
      AlertDialog(
        title: const Text('သတင်းပို့ရန်'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reportReasons.map((reason) {
            return ListTile(
              title: Text(reason),
              onTap: () {
                Get.back();
                chatController.reportUser(widget.room.id, reason);
                Get.snackbar(
                  'ကျေးဇူးတင်ပါသည်',
                  'သင်၏ သတင်းပို့မှုကို လက်ခံရရှိပါပြီ',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ပယ်ဖျက်မည်'),
          ),
        ],
      ),
    );
  }
}