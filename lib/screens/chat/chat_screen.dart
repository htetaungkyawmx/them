import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/data/models/message_model.dart';
import 'package:them_dating_app/providers/chat_provider.dart';
import 'package:them_dating_app/screens/chat/widgets/chat_bubble.dart';
import 'package:them_dating_app/screens/chat/widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String userId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadMessages(widget.matchId);
      chatProvider.initialize(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    final isMe = message.senderId == widget.userId;

                    return ChatBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          // Message input
          MessageInput(
            onSend: (text) {
              final message = MessageModel(
                id: '${widget.matchId}_${DateTime.now().millisecondsSinceEpoch}',
                senderId: widget.userId,
                receiverId: '', // Will be set from match
                content: text,
                timestamp: DateTime.now(),
              );

              Provider.of<ChatProvider>(context, listen: false)
                  .sendMessage(message);

              // Scroll to bottom
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}