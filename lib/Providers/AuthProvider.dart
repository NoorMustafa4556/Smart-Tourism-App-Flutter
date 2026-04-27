import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/UserModel.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userModel;
  bool _isLoading = false;
  bool _isInitialised = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isInitialised => _isInitialised;

  // Check if user is logged in
  AuthProvider() {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // Listen to real-time changes in Firestore
        _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
          if (doc.exists) {
            _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
            _isInitialised = true;
            notifyListeners();
          }
        });
      } else {
        _userModel = null;
        _isInitialised = true;
        notifyListeners();
      }
    });
  }

  // fetchUserData is now mostly for one-time manual refreshes if needed
  Future<void> fetchUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      notifyListeners();
    }
  }

  // Sign Up
  Future<String?> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: 'user',
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        _userModel = newUser;
      }

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await fetchUserData(result.user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // Update User Profile (Extended with Name)
  Future<void> updateUserProfileExtended(String name, String phone, String profilePic) async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'name': name,
        'phone': phone,
        'profilePic': profilePic,
      });
    }
  }

  // Update User Profile (Old version for backward compatibility)
  Future<void> updateUserProfile(String phone, String profilePic) async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'phone': phone,
        'profilePic': profilePic,
      });
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }
}
