import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/config/routes.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/providers/chat_provider.dart';
import 'package:them_dating_app/screens/matches/match_card.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // New message
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No messages yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'When you match with someone, you can chat here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
            itemCount: provider.matches.length,
            itemBuilder: (context, index) {
              final match = provider.matches[index];

              // Determine other user's ID
              final otherUserId = match.userId1 == authProvider.currentUser?.id
                  ? match.userId2
                  : match.userId1;

              return MatchCard(
                match: match,
                otherUserId: otherUserId,  // Required parameter
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chat,
                    arguments: {
                      'matchId': match.id,
                      'userId': authProvider.currentUser?.id ?? '',
                      'userName': 'User', // You'll get this from user data
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}