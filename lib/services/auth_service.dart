import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../utils/constants.dart';

/// Sign up, sign in, sign out, email verification and the user profile.
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection('users');

  User? get currentUser => _auth.currentUser;

  Stream<User?> authChanges() => _auth.authStateChanges();

  Future<void> signUp(String name, String email, String password) async {
    email = email.trim().toLowerCase();
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = AppUser(
      uid: cred.user!.uid,
      name: name.trim(),
      email: email,
      role: roleFromEmail(email),
    );

    await _users.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await cred.user!.sendEmailVerification();
  }

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

  Future<void> signOut() => _auth.signOut();

  Future<void> resendVerification() =>
      _auth.currentUser!.sendEmailVerification();

  // Used by "Forgot password?" and "Change password".
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());

  /// Checks whether the email link was opened yet.
  Future<bool> checkVerified() async {
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) return false;
    await user.getIdToken(true); // so Firestore rules see the verified email
    return true;
  }

  Future<AppUser?> loadProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null;
  }

  Future<void> setHideNameByDefault(String uid, bool value) =>
      _users.doc(uid).update({'hideNameByDefault': value});

  /// text for firebase signin errors.
  static String errorMessage(Object e) {
    final code = e is FirebaseAuthException ? e.code : '';
    return switch (code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email or password is incorrect',
      'email-already-in-use' => 'An account already exists for this email',
      'too-many-requests' => 'Too many attempts. Try again in a minute',
      'network-request-failed' => 'No internet connection',
      _ => 'Something went wrong. Try again',
    };
  }
}
