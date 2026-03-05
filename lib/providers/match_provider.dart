import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:them_dating_app/data/models/user_model.dart';

class MatchProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _potentialMatches = [];
  List<UserModel> _likedUsers = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get potentialMatches => _potentialMatches;
  List<UserModel> get likedUsers => _likedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load potential matches
  Future<void> loadPotentialMatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement matching algorithm
      // For now, get random users
      final snapshot = await _firestore
          .collection('users')
          .limit(10)
          .get();

      _potentialMatches = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Like user
  Future<void> likeUser(String userId) async {
    try {
      // TODO: Create match if both like each other
      _potentialMatches.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Pass user
  Future<void> passUser(String userId) async {
    _potentialMatches.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  // Get matches
  Future<void> loadMatches(String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('userId1', isEqualTo: currentUserId)
          .where('status', isEqualTo: 1) // matched
          .get();

      // TODO: Load matched users
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}