import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:them_dating_app/data/models/user_model.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get rememberMe => _rememberMe;

  AuthProvider() {
    _checkSavedCredentials();
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Check saved credentials
  Future<void> _checkSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      notifyListeners();
    } catch (e) {
      print('Error checking saved credentials: $e');
    }
  }

  // Load saved user from Firestore
  Future<void> loadSavedUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('userId');

      if (savedUserId != null) {
        final doc = await _firestore.collection('users').doc(savedUserId).get();
        if (doc.exists) {
          _currentUser = UserModel.fromMap(doc.data()!);
        }
      }
    } catch (e) {
      print('Error loading saved user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Auth state listener
  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          _currentUser = UserModel.fromMap(doc.data()!);
        } else {
          // Create user document if not exists
          final user = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName,
            phoneNumber: firebaseUser.phoneNumber,
            photos: firebaseUser.photoURL != null ? [firebaseUser.photoURL!] : [],
            interests: [],
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
          );
          await _firestore.collection('users').doc(firebaseUser.uid).set(user.toMap());
          _currentUser = user;
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

  // Email/Password Sign Up
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update profile
      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload();

      // Create user in Firestore
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        photos: [],
        interests: [],
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toMap());

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      _currentUser = user;

      if (_rememberMe) {
        await _saveCredentials(email, password);
      }

      _isLoading = false;
      notifyListeners();

      if (context != null && context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        _showSnackBar(context, '✅ Account created successfully!', Colors.green);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();

      if (context != null && context.mounted) {
        _showSnackBar(context, '❌ ${_getErrorMessage(e.code)}', Colors.red);
      }
      return false;
    }
  }

  // Email/Password Sign In
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    required bool rememberMe,
    BuildContext? context,
  }) async {
    _isLoading = true;
    _error = null;
    _rememberMe = rememberMe;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      // Save credentials if remember me
      if (rememberMe) {
        await _saveCredentials(email, password);
      } else {
        await _clearCredentials();
      }

      _isLoading = false;
      notifyListeners();

      if (context != null && context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        _showSnackBar(context, '✅ Welcome back!', Colors.green);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();

      if (context != null && context.mounted) {
        _showSnackBar(context, '❌ ${_getErrorMessage(e.code)}', Colors.red);
      }
      return false;
    }
  }

  // Google Sign In (Updated for better UX)
  Future<bool> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled sign in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      // Check if user exists in Firestore, if not create
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        final user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName,
          photos: userCredential.user!.photoURL != null ? [userCredential.user!.photoURL!] : [],
          interests: [],
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toMap());
      }

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        _showSnackBar(context, '✅ Signed in with Google!', Colors.green);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        _showSnackBar(context, '❌ Google sign in failed: ${e.message}', Colors.red);
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        _showSnackBar(context, '❌ Google sign in failed', Colors.red);
      }
      return false;
    }
  }

  // Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  // Forgot Password
  Future<void> resetPassword(String email, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();

      _showSnackBar(context, '📧 Password reset email sent!', Colors.blue);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _showSnackBar(context, '❌ Failed to send reset email', Colors.red);
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel updatedUser, BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toMap());

      // Update Firebase Auth display name if changed
      if (updatedUser.name != _currentUser?.name) {
        await _auth.currentUser?.updateDisplayName(updatedUser.name);
      }

      _currentUser = updatedUser;

      _isLoading = false;
      notifyListeners();

      _showSnackBar(context, '✅ Profile updated successfully!', Colors.green);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      _showSnackBar(context, '❌ Update failed', Colors.red);
    }
  }

  // Update phone number (Optional)
  Future<void> updatePhoneNumber(String phoneNumber, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser != null) {
        await _firestore.collection('users').doc(_currentUser!.id).update({
          'phoneNumber': phoneNumber,
        });
        _currentUser = _currentUser!.copyWith(phoneNumber: phoneNumber);
      }

      _isLoading = false;
      notifyListeners();
      _showSnackBar(context, '✅ Phone number updated', Colors.green);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _showSnackBar(context, '❌ Failed to update phone number', Colors.red);
    }
  }

  // Save credentials
  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', true);
    await _secureStorage.write(key: 'savedEmail', value: email);
    await _secureStorage.write(key: 'savedPassword', value: password);
  }

  // Clear credentials
  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', false);
    await _secureStorage.delete(key: 'savedEmail');
    await _secureStorage.delete(key: 'savedPassword');
  }

  // Get error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Show snackbar
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    try {
      // Sign out from Google
      await signOutFromGoogle();

      // Sign out from Firebase
      await _auth.signOut();

      // Clear local user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      _currentUser = null;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
        _showSnackBar(context, '👋 Logged out successfully', Colors.blue);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, '❌ Logout failed', Colors.red);
      }
    }
  }
}