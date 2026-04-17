import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfileController extends ChangeNotifier {
  UserModel _user = UserModel(
    name: 'Alex Johnson',
    email: 'alex.j@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?u=alex',
  );

  UserModel get user => _user;

  void updateProfile({String? name, String? email, String? avatarUrl}) {
    _user = _user.copyWith(name: name, email: email, avatarUrl: avatarUrl);
    notifyListeners();
  }
}
