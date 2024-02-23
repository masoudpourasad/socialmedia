import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserViewModel extends ChangeNotifier {
  User? _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _user;

  Future<void> setUser() async {
    try {
      _user = _auth.currentUser;
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user: $e');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }
}
