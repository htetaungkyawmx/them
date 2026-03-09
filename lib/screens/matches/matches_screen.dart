import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/config/routes.dart';
import 'package:them_dating_app/core/theme/theme_provider.dart';
import 'package:them_dating_app/data/models/match_model.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/providers/match_provider.dart';

import '../../data/models/user_model.dart';
import '../home/profile_detail_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);
    final matchProvider = Provider.of<MatchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          tabs: const [
            Tab(text: 'New Matches'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authProvider.currentUser != null) {
            await matchProvider.loadMatches(authProvider.currentUser!.id);
          }
        },
        color: Colors.red,
        child: TabBarView(
          controller: _tabController,
          children: [
            // New Matches Tab
            _buildNewMatches(context, matchProvider, authProvider),

            // Messages Tab
            _buildMessages(context, matchProvider, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildNewMatches(
      BuildContext context,
      MatchProvider matchProvider,
      AuthProvider authProvider,
      ) {
    if (matchProvider.isLoading && matchProvider.matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (matchProvider.matches.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: matchProvider.matches.length,
      itemBuilder: (context, index) {
        final match = matchProvider.matches[index];
        return FutureBuilder<UserModel?>(
          future: matchProvider.getMatchedUser(
            match.id,
            authProvider.currentUser!.id,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildShimmerCard();
            }
            final user = snapshot.data!;
            return OpenContainer(
              closedColor: Colors.transparent,
              closedElevation: 0,
              openElevation: 0,
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (context, action) {
                return ProfileDetailScreen(userId: user.id);
              },
              closedBuilder: (context, action) {
                return _buildMatchCard(context, user);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessages(
      BuildContext context,
      MatchProvider matchProvider,
      AuthProvider authProvider,
      ) {
    if (matchProvider.isLoading && matchProvider.matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (matchProvider.matches.isEmpty) {
      return _buildEmptyMessagesState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matchProvider.matches.length,
      itemBuilder: (context, index) {
        final match = matchProvider.matches[index];
        return FutureBuilder<UserModel?>(
          future: matchProvider.getMatchedUser(
            match.id,
            authProvider.currentUser!.id,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildShimmerListItem();
            }
            final user = snapshot.data!;
            return _buildMessageItem(context, match, user, authProvider);
          },
        );
      },
    );
  }

  Widget _buildMatchCard(BuildContext context, UserModel user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: user.photos.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: user.photos.first,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40),
                ),
              )
                  : Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.person, size: 40),
                ),
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.age ?? ''} • ${user.distance ?? 0}km',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (match.lastMessageAt != null)
              Text(
                _formatTime(match.lastMessageAt!),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
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

  Widget _buildShimmerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  height: 12,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerListItem() {
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No matches yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start swiping to find your perfect match!',
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
            child: const Text('Start Swiping'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessagesState(BuildContext context) {
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
        ],
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