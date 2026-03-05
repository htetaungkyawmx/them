import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/providers/match_provider.dart';
import 'package:them_dating_app/screens/home/widgets/profile_card.dart';
import 'package:them_dating_app/screens/matches/matches_screen.dart';  // Add this import
import 'package:them_dating_app/screens/profile/profile_screen.dart';   // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DiscoverScreen(),
      const MatchesScreen(),  // Now this will work
      const ProfileScreen(),   // Now this will work
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Discover Screen
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load potential matches when screen initializes
      final matchProvider = Provider.of<MatchProvider>(context, listen: false);
      matchProvider.loadPotentialMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // Show filter options
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Consumer<MatchProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.potentialMatches.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.potentialMatches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No more profiles to show',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Check back later or adjust your filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadPotentialMatches();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return PageView.builder(
            itemCount: provider.potentialMatches.length,
            itemBuilder: (context, index) {
              final user = provider.potentialMatches[index];
              return ProfileCard(
                user: user,
                onLike: () => provider.likeUser(user.id),
                onPass: () => provider.passUser(user.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Age range
            ListTile(
              title: const Text('Age Range'),
              subtitle: const Text('18 - 35'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to age range picker
              },
            ),
            // Distance
            ListTile(
              title: const Text('Distance'),
              subtitle: const Text('Within 50 km'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to distance picker
              },
            ),
            // Interests
            ListTile(
              title: const Text('Interests'),
              subtitle: const Text('Select interests'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to interests picker
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Apply filters
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}