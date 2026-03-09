import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/config/routes.dart';
import 'package:them_dating_app/core/constants/app_colors.dart';
import 'package:them_dating_app/providers/auth_provider.dart';
import 'package:them_dating_app/providers/match_provider.dart';
import 'package:them_dating_app/screens/home/widgets/profile_card.dart';
import 'package:them_dating_app/screens/matches/matches_screen.dart';
import 'package:them_dating_app/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DiscoverScreen(),
      const MatchesScreen(),
      const ProfileScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      try {
        // Try to get location, but don't fail if it doesn't work
        await matchProvider.getCurrentLocation();
        await matchProvider.loadPotentialMatches(authProvider.currentUser!.id);
        await matchProvider.loadMatches(authProvider.currentUser!.id);
      } catch (e) {
        print('Error loading data: $e');
        setState(() {
          _errorMessage = 'Failed to load some data';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Something went wrong', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(_errorMessage!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                  });
                  _loadInitialData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
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
  final PageController _pageController = PageController();
  bool _showFilters = false;

  int _maxDistance = 50;
  RangeValues _ageRange = const RangeValues(18, 50);
  String _selectedGender = 'Everyone';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final matchProvider = Provider.of<MatchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (authProvider.currentUser != null) {
                matchProvider.loadPotentialMatches(
                  authProvider.currentUser!.id,
                  maxDistance: _maxDistance,
                  ageMin: _ageRange.start.toInt(),
                  ageMax: _ageRange.end.toInt(),
                  gender: _selectedGender,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            _buildFilters(authProvider, matchProvider),
          Expanded(
            child: matchProvider.isLoading && matchProvider.potentialMatches.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Finding matches near you...'),
                ],
              ),
            )
                : matchProvider.potentialMatches.isEmpty
                ? _buildEmptyState(authProvider, matchProvider)
                : PageView.builder(
              controller: _pageController,
              itemCount: matchProvider.potentialMatches.length,
              itemBuilder: (context, index) {
                final user = matchProvider.potentialMatches[index];
                return ProfileCard(
                  user: user,
                  onLike: () {
                    if (authProvider.currentUser != null) {
                      matchProvider.likeUser(
                        authProvider.currentUser!.id,
                        user.id,
                      );
                    }
                  },
                  onPass: () {
                    if (authProvider.currentUser != null) {
                      matchProvider.passUser(
                        authProvider.currentUser!.id,
                        user.id,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AuthProvider authProvider, MatchProvider matchProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Text('Max Distance: $_maxDistance km'),
          Slider(
            value: _maxDistance.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _maxDistance = value.round();
              });
            },
          ),

          const SizedBox(height: 8),

          Text('Age: ${_ageRange.start.round()} - ${_ageRange.end.round()}'),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 80,
            divisions: 62,
            activeColor: AppColors.primary,
            onChanged: (values) {
              setState(() {
                _ageRange = values;
              });
            },
          ),

          const SizedBox(height: 8),

          const Text('Show:'),
          DropdownButton<String>(
            value: _selectedGender,
            isExpanded: true,
            items: ['Everyone', 'Male', 'Female'].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = false;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (authProvider.currentUser != null) {
                      matchProvider.loadPotentialMatches(
                        authProvider.currentUser!.id,
                        maxDistance: _maxDistance,
                        ageMin: _ageRange.start.toInt(),
                        ageMax: _ageRange.end.toInt(),
                        gender: _selectedGender == 'Everyone' ? null : _selectedGender,
                      );
                    }
                    setState(() {
                      _showFilters = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AuthProvider authProvider, MatchProvider matchProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No more profiles',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            !matchProvider.hasLocationPermission
                ? 'Enable location to find people near you'
                : 'Check back later or adjust your filters',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (!matchProvider.hasLocationPermission)
            ElevatedButton(
              onPressed: () {
                matchProvider.getCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Enable Location'),
            )
          else
            ElevatedButton(
              onPressed: () {
                if (authProvider.currentUser != null) {
                  matchProvider.loadPotentialMatches(
                    authProvider.currentUser!.id,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Refresh'),
            ),
        ],
      ),
    );
  }
}