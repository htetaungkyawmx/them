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
        try {
          final doc = await _firestore.collection('users').doc(savedUserId).get();
          if (doc.exists) {
            final userData = doc.data() as Map<String, dynamic>;
            _currentUser = UserModel.fromMap(userData);
            print('✅ User loaded from Firestore: ${_currentUser?.email}');
          }
        } catch (e) {
          print('⚠️ Firestore error in loadSavedUser: $e');
          final userJson = prefs.getString('userData');
          if (userJson != null) {
            try {
              final userData = json.decode(userJson);
              _currentUser = UserModel.fromMap(userData);
              print('✅ User loaded from SharedPreferences');
            } catch (e) {
              print('❌ Error parsing user data: $e');
            }
          }
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
    print('🔄 Auth state changed: ${firebaseUser?.email ?? 'Logged out'}');

    if (firebaseUser != null) {
      _isLoading = true;
      notifyListeners();

      try {
        try {
          final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (doc.exists) {
            final userData = doc.data() as Map<String, dynamic>;
            _currentUser = UserModel.fromMap(userData);
            print('✅ User loaded from Firestore: ${_currentUser?.email}');
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
            print('✅ New user created in Firestore: ${user.email}');
          }
        } catch (e) {
          print('⚠️ Firestore error in auth state change: $e');
          _currentUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName,
            phoneNumber: firebaseUser.phoneNumber,
            photos: firebaseUser.photoURL != null ? [firebaseUser.photoURL!] : [],
            interests: [],
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
          );
        }

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', firebaseUser.uid);
        if (_currentUser != null) {
          await prefs.setString('userData', json.encode(_currentUser!.toMap()));
        }

      } catch (e) {
        _error = e.toString();
        print('❌ Error in auth state change: $e');
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
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Creating account for: $email');

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

      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toMap());
        print('✅ User saved to Firestore');
      } catch (e) {
        print('⚠️ Could not save to Firestore: $e');
      }

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);
      await prefs.setString('userData', json.encode(user.toMap()));

      _currentUser = user;

      if (_rememberMe) {
        await _saveCredentials(email, password);
      }

      _isLoading = false;
      notifyListeners();

      // Navigate to home immediately
      if (context != null && context.mounted) {
        // Small delay to ensure state is updated
        Future.microtask(() {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                    (route) => false
            );
          }
        });
        _showSnackBar(context, '✅ Account created successfully!', Colors.green);
      }
      return true;

    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();

      print('❌ Sign up error: ${e.code} - ${e.message}');

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
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    _rememberMe = rememberMe;
    notifyListeners();

    try {
      print('🔐 Signing in: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      if (rememberMe) {
        await _saveCredentials(email, password);
      } else {
        await _clearCredentials();
      }

      _isLoading = false;
      notifyListeners();

      // Navigate to home immediately
      if (context != null && context.mounted) {
        Future.microtask(() {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                    (route) => false
            );
          }
        });
        _showSnackBar(context, '✅ Welcome back!', Colors.green);
      }
      return true;

    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();

      print('❌ Sign in error: ${e.code} - ${e.message}');

      if (context != null && context.mounted) {
        _showSnackBar(context, '❌ ${_getErrorMessage(e.code)}', Colors.red);
      }
      return false;
    }
  }

  // Google Sign In (FIXED - No navigation flags)
  Future<bool> signInWithGoogle(BuildContext context) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🌐 Starting Google Sign In');

      // Try to sign in directly
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        print('ℹ️ Google sign in cancelled by user');
        return false;
      }

      print('✅ Google user selected: ${googleUser.email}');

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      print('✅ Firebase sign in successful: ${userCredential.user?.email}');

      // Save user ID locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userCredential.user!.uid);

      // Check/Create user in Firestore
      try {
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
          print('✅ New user created in Firestore from Google');

          // Save to local storage
          await prefs.setString('userData', json.encode(user.toMap()));
        }
      } catch (e) {
        print('⚠️ Could not access Firestore: $e');
      }

      _isLoading = false;
      notifyListeners();

      // Navigate to home immediately
      if (context.mounted) {
        Future.microtask(() {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                    (route) => false
            );
          }
        });
        _showSnackBar(context, '✅ Signed in with Google!', Colors.green);
      }
      return true;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();

      print('❌ Google sign in error: $e');

      if (context.mounted) {
        _showSnackBar(context, '❌ Google sign in failed: ${e.toString()}', Colors.red);
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
      try {
        await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toMap());
      } catch (e) {
        print('⚠️ Could not update Firestore: $e');
      }

      if (updatedUser.name != _currentUser?.name) {
        await _auth.currentUser?.updateDisplayName(updatedUser.name);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(updatedUser.toMap()));

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
        try {
          await _firestore.collection('users').doc(_currentUser!.id).update({
            'phoneNumber': phoneNumber,
          });
        } catch (e) {
          print('⚠️ Could not update Firestore: $e');
        }
        _currentUser = _currentUser!.copyWith(phoneNumber: phoneNumber);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', json.encode(_currentUser!.toMap()));
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Logout (Manual logout only)
  Future<void> logout(BuildContext context) async {
    try {
      print('🚪 Logging out...');

      await _googleSignIn.signOut();
      await _auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('userData');
      await prefs.remove('rememberMe');

      _currentUser = null;
      notifyListeners();

      if (context.mounted) {
        Future.microtask(() {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                    (route) => false
            );
          }
        });
        _showSnackBar(context, '👋 Logged out successfully', Colors.blue);
      }

      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      if (context.mounted) {
        _showSnackBar(context, '❌ Logout failed', Colors.red);
      }
    }
  }
}