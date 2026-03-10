import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/core/theme/theme_provider.dart';
import 'package:them_dating_app/data/models/message_model.dart';
import 'package:them_dating_app/providers/chat_provider.dart';
import 'package:them_dating_app/screens/chat/widgets/chat_bubble.dart';
import 'package:them_dating_app/screens/chat/widgets/message_input.dart';
import 'package:them_dating_app/screens/video_call/webrtc_call_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String userId;
  final String userName;
  final String? userPhoto;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.userId,
    required this.userName,
    this.userPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEmojiPickerVisible = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadMessages(widget.matchId);
      chatProvider.initialize(widget.userId);

      // Set user online
      chatProvider.setUserOnline(widget.userId, true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      chatProvider.setUserOnline(widget.userId, true);
    } else if (state == AppLifecycleState.paused) {
      chatProvider.setUserOnline(widget.userId, false);
    }
  }

  void _showEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
    if (_isEmojiPickerVisible) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  void _startVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          roomId: 'call_${widget.matchId}',
          userName: widget.userName,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _startAudioCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio call coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final message = MessageModel(
        id: '${widget.matchId}_${DateTime.now().millisecondsSinceEpoch}',
        senderId: widget.userId,
        receiverId: '',
        content: text,
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      await Provider.of<ChatProvider>(context, listen: false)
          .sendMessage(message);

      _messageController.clear();
      setState(() {
        _isEmojiPickerVisible = false;
        _isTyping = false;
      });

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _sendVoice() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice recording coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final chatProvider = Provider.of<ChatProvider>(context);

    // Get online status from provider
    final isOnline = chatProvider.onlineUsers[widget.userId] ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // User avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: widget.userPhoto != null
                        ? DecorationImage(
                      image: NetworkImage(widget.userPhoto!),
                      fit: BoxFit.cover,
                    )
                        : null,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                    ),
                  ),
                  child: widget.userPhoto == null
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _isTyping ? 'Typing...' : (isOnline ? 'Online' : 'Offline'),
                    style: TextStyle(
                      fontSize: 12,
                      color: _isTyping ? Colors.orange : (isOnline ? Colors.green : Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _startAudioCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_profile',
                child: Text('View Profile'),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Text('Search in Conversation'),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Text('Mute Notifications'),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('Report User'),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Text('Block User'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'view_profile':
                  _showUserProfile();
                  break;
                case 'search':
                  _showSearchDialog();
                  break;
                case 'mute':
                  _toggleMute();
                  break;
                case 'report':
                  _showReportDialog();
                  break;
                case 'block':
                  _showBlockDialog();
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEmojiPickerVisible = false;
                });
                _focusNode.unfocus();
              },
              child: Container(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                child: chatProvider.isLoading && chatProvider.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : chatProvider.messages.isEmpty
                    ? _buildEmptyChat()
                    : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    final isMe = message.senderId == widget.userId;
                    final showDate = index == 0 ||
                        !_isSameDay(
                          chatProvider.messages[index].timestamp,
                          chatProvider.messages[index - 1].timestamp,
                        );

                    return Column(
                      children: [
                        if (showDate)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              DateFormat('MMM dd, yyyy').format(message.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ChatBubble(
                          message: message,
                          isMe: isMe,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Emoji picker
          if (_isEmojiPickerVisible)
            Container(
              height: 300,
              color: isDark ? Colors.grey[900] : Colors.white,
              child: EmojiPicker(
                onEmojiSelected: (Category? category, Emoji emoji) {
                  _messageController.text += emoji.emoji;
                },
                onBackspacePressed: () {
                  if (_messageController.text.isNotEmpty) {
                    _messageController.text = _messageController.text
                        .substring(0, _messageController.text.length - 1);
                  }
                },
                config: Config(
                  emojiViewConfig: EmojiViewConfig(
                    columns: 7,
                    emojiSizeMax: 32.0,
                  ),
                ),
              ),
            ),

          // Message input
          MessageInput(
            controller: _messageController,
            focusNode: _focusNode,
            onSend: _sendMessage,
            onImagePressed: _sendImage,
            onVoicePressed: _sendVoice,
            onEmojiPressed: _showEmojiPicker,
            onTypingChanged: (isTyping) {
              setState(() {
                _isTyping = isTyping;
              });
              // Send typing indicator to server
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              chatProvider.sendTypingIndicator(widget.matchId, widget.userId, isTyping);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.red.withOpacity(0.1),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 50,
              color: Colors.red.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start the conversation',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startVideoCall,
            icon: const Icon(Icons.videocam),
            label: const Text('Start Video Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserProfile() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final isOnline = chatProvider.onlineUsers[widget.userId] ?? false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.userPhoto != null
                  ? NetworkImage(widget.userPhoto!)
                  : null,
              child: widget.userPhoto == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionChip(Icons.message, 'Message', () {
                  Navigator.pop(context);
                }),
                _buildActionChip(Icons.phone, 'Audio', () {
                  Navigator.pop(context);
                  _startAudioCall();
                }),
                _buildActionChip(Icons.videocam, 'Video', () {
                  Navigator.pop(context);
                  _startVideoCall();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.red),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search messages...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            // Implement search
          },
        ),
      ),
    );
  }

  void _toggleMute() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications muted'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: const Text('Are you sure you want to report this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User reported'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User blocked'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.setUserOnline(widget.userId, false);
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}