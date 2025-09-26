// lib/providers/auth_provider.dart (actualizado)
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:urban_market/models/user_model.dart';
import 'package:urban_market/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  fb_auth.User? _firebaseUser;
  User? _currentUser;

  fb_auth.User? get firebaseUser => _firebaseUser;
  User? get currentUser => _currentUser;

  bool get isAuth {
    return _firebaseUser != null;
  }

  String? get userId {
    return _firebaseUser?.uid;
  }

  String? get userEmail {
    return _firebaseUser?.email;
  }

  String? get userRole {
    return _currentUser?.role;
  }

  Future<void> login(String email, String password) async {
    try {
      final userCredential =
          await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = userCredential.user;

      // Cargar el usuario desde Firestore
      if (_firebaseUser != null) {
        _currentUser = await FirestoreService.getUser(_firebaseUser!.uid);
      }

      notifyListeners();
    } catch (error) {
      debugPrint('Login error: $error');
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String name, String phone,
      String role) async {
    try {
      final userCredential =
          await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = userCredential.user;

      if (_firebaseUser != null) {
        // Crear el usuario en Firestore
        final newUser = User(
          id: _firebaseUser!.uid,
          name: name,
          email: email,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
        );

        await FirestoreService.createUser(newUser);
        _currentUser = newUser;
      }

      notifyListeners();
    } catch (error) {
      debugPrint('Signup error: $error');
      rethrow;
    }
  }

  Future<void> logout() async {
    await fb_auth.FirebaseAuth.instance.signOut();
    _firebaseUser = null;
    _currentUser = null;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
