import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:them_dating_app/data/models/match_model.dart';
import 'package:them_dating_app/data/models/user_model.dart';

class MatchProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _potentialMatches = [];
  List<MatchModel> _matches = [];
  List<UserModel> _likedUsers = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  // Getters
  List<UserModel> get potentialMatches => _potentialMatches;
  List<MatchModel> get matches => _matches;
  List<UserModel> get likedUsers => _likedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Calculate distance between two users
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  // Load potential matches based on preferences
  Future<void> loadPotentialMatches(String currentUserId, {
    int maxDistance = 50,
    int ageMin = 18,
    int ageMax = 50,
    String? gender,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get current user data
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!currentUserDoc.exists) return;

      final currentUser = UserModel.fromMap(currentUserDoc.data()!);

      // Get already liked/rejected users
      final likedSnapshot = await _firestore
          .collection('matches')
          .where('userId1', isEqualTo: currentUserId)
          .get();

      final excludedIds = likedSnapshot.docs
          .map((doc) => doc['userId2'] as String)
          .toList();

      excludedIds.add(currentUserId); // Exclude self

      // Query potential matches
      Query query = _firestore.collection('users');

      // Filter by age
      if (ageMin > 0) {
        // Note: You'll need to store age in Firestore or calculate from DOB
      }

      // Filter by gender preference
      if (gender != null && gender != 'Everyone') {
        query = query.where('gender', isEqualTo: gender);
      }

      final snapshot = await query.limit(20).get();

      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        if (excludedIds.contains(doc.id)) continue;

        // FIXED: Use doc.data() as Map<String, dynamic>
        final userData = doc.data() as Map<String, dynamic>;
        UserModel user = UserModel.fromMap(userData);

        // Calculate distance if location available
        if (currentUser.latitude != null &&
            currentUser.longitude != null &&
            user.latitude != null &&
            user.longitude != null) {
          double distance = _calculateDistance(
            currentUser.latitude!,
            currentUser.longitude!,
            user.latitude!,
            user.longitude!,
          );

          if (distance <= maxDistance) {
            user = user.copyWith(distance: distance.round());
            users.add(user);
          }
        } else {
          users.add(user);
        }
      }

      // Sort by distance
      users.sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));

      _potentialMatches = users;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Like a user
  Future<void> likeUser(String currentUserId, String targetUserId) async {
    try {
      final matchId = _generateMatchId(currentUserId, targetUserId);
      final matchRef = _firestore.collection('matches').doc(matchId);

      final matchDoc = await matchRef.get();

      if (matchDoc.exists) {
        // Update existing match
        final matchData = matchDoc.data() as Map<String, dynamic>;
        final match = MatchModel.fromMap(matchData);

        if (match.userId2 == currentUserId && match.status == MatchStatus.pending) {
          // It's a match!
          await matchRef.update({
            'status': MatchStatus.matched.index,
            'isMatched': true,
          });

          // Create chat room
          await _createChatRoom(matchId, currentUserId, targetUserId);
        }
      } else {
        // Create new like
        await matchRef.set({
          'id': matchId,
          'userId1': currentUserId,
          'userId2': targetUserId,
          'status': MatchStatus.pending.index,
          'createdAt': DateTime.now().toIso8601String(),
          'isLiked': true,
          'isMatched': false,
        });
      }

      // Remove from potential matches
      _potentialMatches.removeWhere((user) => user.id == targetUserId);
      notifyListeners();

    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Pass a user
  Future<void> passUser(String currentUserId, String targetUserId) async {
    try {
      final matchId = _generateMatchId(currentUserId, targetUserId);

      await _firestore.collection('matches').doc(matchId).set({
        'id': matchId,
        'userId1': currentUserId,
        'userId2': targetUserId,
        'status': MatchStatus.rejected.index,
        'createdAt': DateTime.now().toIso8601String(),
        'isLiked': false,
        'isMatched': false,
      });

      _potentialMatches.removeWhere((user) => user.id == targetUserId);
      notifyListeners();

    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Generate match ID (consistent order)
  String _generateMatchId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Create chat room
  Future<void> _createChatRoom(String matchId, String uid1, String uid2) async {
    await _firestore.collection('chats').doc(matchId).set({
      'id': matchId,
      'participants': [uid1, uid2],
      'createdAt': DateTime.now().toIso8601String(),
      'lastMessage': '',
      'lastMessageAt': DateTime.now().toIso8601String(),
    });
  }

  // Load matches for current user
  Future<void> loadMatches(String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('status', isEqualTo: MatchStatus.matched.index)
          .where('userId1', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      final snapshot2 = await _firestore
          .collection('matches')
          .where('status', isEqualTo: MatchStatus.matched.index)
          .where('userId2', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      _matches = [
        ...snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return MatchModel.fromMap(data);
        }),
        ...snapshot2.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return MatchModel.fromMap(data);
        }),
      ];

      // Sort by last message time
      _matches.sort((a, b) =>
          (b.lastMessageAt ?? DateTime.now()).compareTo(a.lastMessageAt ?? DateTime.now())
      );

    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get matched user details
  Future<UserModel?> getMatchedUser(String matchId, String currentUserId) async {
    try {
      final matchDoc = await _firestore.collection('matches').doc(matchId).get();
      if (!matchDoc.exists) return null;

      final matchData = matchDoc.data() as Map<String, dynamic>;
      final match = MatchModel.fromMap(matchData);
      final otherUserId = match.userId1 == currentUserId ? match.userId2 : match.userId1;

      final userDoc = await _firestore.collection('users').doc(otherUserId).get();
      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      return UserModel.fromMap(userData);
    } catch (e) {
      print('Error getting matched user: $e');
      return null;
    }
  }

  // Clear potential matches
  void clearPotentialMatches() {
    _potentialMatches.clear();
    notifyListeners();
  }
}