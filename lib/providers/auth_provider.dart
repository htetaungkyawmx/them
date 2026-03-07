import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:them_dating_app/data/models/user_model.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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

      if (_rememberMe) {
        final savedEmail = await _secureStorage.read(key: 'savedEmail');
        if (savedEmail != null) {
          // Auto login logic here
        }
      }
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

  // Google Sign In
  Future<bool> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        _showSnackBar(context, '✅ Signed in with Google!', Colors.green);
      }
      return true;
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

  // Apple Sign In (iOS)
  Future<bool> signInWithApple(BuildContext context) async {
    if (!await SignInWithApple.isAvailable()) {
      _showSnackBar(context, '❌ Apple Sign In is not available on this device', Colors.red);
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        _showSnackBar(context, '✅ Signed in with Apple!', Colors.green);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        _showSnackBar(context, '❌ Apple sign in failed', Colors.red);
      }
      return false;
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
        final updatedUser = _currentUser!.copyWith(phoneNumber: phoneNumber);
        await _firestore.collection('users').doc(_currentUser!.id).update({
          'phoneNumber': phoneNumber,
        });
        _currentUser = updatedUser;
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
      default:
        return 'Authentication failed';
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
      ),
    );
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
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