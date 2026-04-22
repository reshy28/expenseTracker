import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../root/services/firebase_service.dart';
import '../models/user_model.dart';

class ProfileController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel _user = UserModel(name: 'User', email: '');

  ProfileController() {
    _init();
  }

  void _init() {
    // 1. Initial sync with Firebase Auth for immediate display
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = _user.copyWith(
        name: currentUser.displayName ?? 'User',
        email: currentUser.email ?? '',
      );
    }

    // 2. Listen to profile updates from the specialized Firestore subcollection
    _firestoreService.getProfile().listen((user) {
      if (user != null) {
        _user = user;
        notifyListeners();
      } else if (currentUser != null) {
        // If Firestore document doesn't exist, ensure we're at least using Auth data
        _user = _user.copyWith(
          name: currentUser.displayName ?? 'User',
          email: currentUser.email ?? '',
        );
        notifyListeners();
      }
    });
  }

  UserModel get user => _user;

  Future<void> updateProfile({String? name, String? email}) async {
    _user = _user.copyWith(name: name, email: email);

    // Persist to specialized profile subcollection
    await _firestoreService.saveProfile(_user);

    notifyListeners();
  }
}
