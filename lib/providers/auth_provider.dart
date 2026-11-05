import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

enum AuthStatus { loading, signedOut, unverified, signedIn }

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _service.authChanges().listen(_onAuthChanged);
  }

  final _service = AuthService();

  AuthStatus status = AuthStatus.loading;
  AppUser? user;
  bool busy = false;
  String? error;

  String get email => _service.currentUser?.email ?? '';

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      user = null;
      status = AuthStatus.signedOut;
    } else if (!firebaseUser.emailVerified) {
      status = AuthStatus.unverified;
    } else {
      await _loadProfile();
    }
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final fbUser = _service.currentUser!;
    final email = fbUser.email!;
    user =
        await _service.loadProfile(fbUser.uid) ??
        AppUser(
          uid: fbUser.uid,
          name: email.split('@').first,
          email: email,
          role: roleFromEmail(email),
        );
    status = AuthStatus.signedIn;
  }

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      error = AuthService.errorMessage(e);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<bool> signUp(String name, String email, String password) =>
      _run(() => _service.signUp(name, email, password));

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _service.sendPasswordReset(email));

  Future<bool> resendVerification() => _run(_service.resendVerification);

  Future<void> signOut() => _service.signOut();

  Future<bool> checkVerified() => _run(() async {
    if (!await _service.checkVerified()) {
      throw Exception('not verified');
    }
    await _loadProfile();
  });

  Future<void> setHideNameByDefault(bool value) async {
    user!.hideNameByDefault = value;
    notifyListeners();
    await _service.setHideNameByDefault(user!.uid, value);
  }
}
