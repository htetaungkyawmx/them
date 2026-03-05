import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:them_dating_app/data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          _currentUser = UserModel.fromMap(doc.data()!);
        }
      } catch (e) {
        _error = e.toString();
      }

      _isLoading = false;
      notifyListeners();
    } else {
      _currentUser = null;
      notifyListeners();
    }
  }

  // Login with phone number
  Future<void> loginWithPhone(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (error) {
          _error = error.message;
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (verificationId, resendToken) {
          // Navigate to OTP screen
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String verificationId, String smsCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        // New user - navigate to registration
        return false;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<void> registerUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      _currentUser = user;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toMap());
      _currentUser = updatedUser;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}