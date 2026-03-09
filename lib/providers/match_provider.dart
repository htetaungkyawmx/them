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
  bool _hasLocationPermission = false;

  // Getters
  List<UserModel> get potentialMatches => _potentialMatches;
  List<MatchModel> get matches => _matches;
  List<UserModel> get likedUsers => _likedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  bool get hasLocationPermission => _hasLocationPermission;

  // Get current location with better error handling (FIXED for geolocator)
  Future<void> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services are disabled');
        _hasLocationPermission = false;
        notifyListeners();
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permissions are denied');
          _hasLocationPermission = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permissions are permanently denied');
        _hasLocationPermission = false;
        notifyListeners();
        return;
      }

      // Get current position (FIXED: using simpler approach)
      _currentPosition = await Geolocator.getCurrentPosition();

      _hasLocationPermission = true;
      print('✅ Location obtained: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      notifyListeners();

    } catch (e) {
      print('⚠️ Error getting location: $e');
      _hasLocationPermission = false;
      // Don't throw error, just continue without location
    }
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
      if (!currentUserDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final currentUser = UserModel.fromMap(currentUserDoc.data() as Map<String, dynamic>);

      // Get already liked/rejected users
      final likedSnapshot = await _firestore
          .collection('matches')
          .where('userId1', isEqualTo: currentUserId)
          .get();

      final excludedIds = likedSnapshot.docs
          .map((doc) => doc['userId2'] as String)
          .toList();

      excludedIds.add(currentUserId);

      // Query potential matches
      Query query = _firestore.collection('users');

      if (gender != null && gender != 'Everyone') {
        query = query.where('gender', isEqualTo: gender);
      }

      final snapshot = await query.limit(20).get();

      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        if (excludedIds.contains(doc.id)) continue;

        final userData = doc.data() as Map<String, dynamic>;
        UserModel user = UserModel.fromMap(userData);

        // Calculate distance if location available
        if (_hasLocationPermission &&
            currentUser.latitude != null &&
            currentUser.longitude != null &&
            user.latitude != null &&
            user.longitude != null) {
          double distance = Geolocator.distanceBetween(
            currentUser.latitude!,
            currentUser.longitude!,
            user.latitude!,
            user.longitude!,
          ) / 1000; // Convert to km

          if (distance <= maxDistance) {
            user = user.copyWith(distance: distance.round());
            users.add(user);
          }
        } else {
          users.add(user);
        }
      }

      // Sort by distance (if available)
      users.sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));

      _potentialMatches = users;
    } catch (e) {
      _error = e.toString();
      print('Error loading matches: $e');
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
        final matchData = matchDoc.data() as Map<String, dynamic>;
        final match = MatchModel.fromMap(matchData);

        if (match.userId2 == currentUserId && match.status == MatchStatus.pending) {
          await matchRef.update({
            'status': MatchStatus.matched.index,
            'isMatched': true,
          });

          await _createChatRoom(matchId, currentUserId, targetUserId);
        }
      } else {
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

  String _generateMatchId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _createChatRoom(String matchId, String uid1, String uid2) async {
    await _firestore.collection('chats').doc(matchId).set({
      'id': matchId,
      'participants': [uid1, uid2],
      'createdAt': DateTime.now().toIso8601String(),
      'lastMessage': '',
      'lastMessageAt': DateTime.now().toIso8601String(),
    });
  }

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

      _matches.sort((a, b) =>
          (b.lastMessageAt ?? DateTime.now()).compareTo(a.lastMessageAt ?? DateTime.now())
      );

    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

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

  void clearPotentialMatches() {
    _potentialMatches.clear();
    notifyListeners();
  }
}