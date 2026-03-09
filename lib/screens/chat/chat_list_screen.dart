import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/config/routes.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/core/theme/theme_provider.dart';
import 'package:them_dating_app/data/models/match_model.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/providers/chat_provider.dart';
import 'package:them_dating_app/screens/video_call/room_list_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/user_model.dart';
import '../video_call/webrtc_call_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Video Rooms'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomListScreen(
                    currentUserId: authProvider.currentUser!.id,
                    currentUserName: authProvider.currentUser!.name ?? 'User',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Chats Tab
          _buildChatsTab(context, authProvider, chatProvider),

          // Video Rooms Tab
          _buildVideoRoomsTab(context, authProvider),
        ],
      ),
    );
  }

  Widget _buildChatsTab(
      BuildContext context,
      AuthProvider authProvider,
      ChatProvider chatProvider,
      ) {
    if (chatProvider.isLoading && chatProvider.matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'When you match with someone, you can chat here',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to discover tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text('Find Matches'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.matches.length,
      itemBuilder: (context, index) {
        final match = chatProvider.matches[index];
        return FutureBuilder<UserModel?>(
          future: _getMatchedUser(match, authProvider.currentUser!.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildShimmerItem();
            }
            final user = snapshot.data!;
            return _buildChatItem(context, match, user, authProvider);
          },
        );
      },
    );
  }

  Widget _buildVideoRoomsTab(BuildContext context, AuthProvider authProvider) {
    return RoomListScreen(
      currentUserId: authProvider.currentUser!.id,
      currentUserName: authProvider.currentUser!.name ?? 'User',
    );
  }

  Widget _buildChatItem(
      BuildContext context,
      MatchModel match,
      UserModel user,
      AuthProvider authProvider,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: user.photos.isNotEmpty
              ? CachedNetworkImageProvider(user.photos.first)
              : null,
          child: user.photos.isEmpty
              ? const Icon(Icons.person, size: 30)
              : null,
        ),
        title: Text(
          user.name ?? 'User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              match.lastMessage ?? 'Say hello! 👋',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.red),
              onPressed: () {
                _startVideoCall(context, user, authProvider.currentUser!.id);
              },
            ),
            if (match.lastMessageAt != null)
              Text(
                _formatTime(match.lastMessageAt!),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.chat,
            arguments: {
              'matchId': match.id,
              'userId': authProvider.currentUser!.id,
              'userName': user.name ?? 'User',
              'userPhoto': user.photos.isNotEmpty ? user.photos.first : null,
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserModel?> _getMatchedUser(MatchModel match, String currentUserId) async {
    // Implement this method to get user details
    return null;
  }

  void _startVideoCall(BuildContext context, UserModel user, String currentUserId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          roomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
          userName: user.name ?? 'User',
          userId: currentUserId,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}