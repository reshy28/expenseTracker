import 'package:firebase_auth/firebase_auth.dart';
import '../../root/services/firebase_service.dart';
import '../../settings/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of auth state changes — null means logged out
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Register with email & password, then update display name
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 1. Update Auth display name
    await credential.user?.updateDisplayName(name);

    // 2. Create initial Profile document in Firestore so controllers can see it
    if (credential.user != null) {
      final user = UserModel(name: name, email: email);
      await FirestoreService().saveProfile(user);
    }
    return credential;
  }

  /// Sign in with email & password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete Account permanently
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Wipe all data from Firestore first
    await FirestoreService().dangerousWipeAllMyData();

    // 2. Delete the Auth account
    // Note: Re-authentication might be required if the user has not logged in recently.
    await user.delete();
  }
}
