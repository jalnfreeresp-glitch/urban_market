// lib/providers/auth_provider.dart (Corregido)

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:urban_market/models/user_model.dart'; // Asegúrate que esta ruta es correcta y contiene la clase 'User'
import 'package:urban_market/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  User? _user; // CORREGIDO: UserModel -> User
  bool _isLoading = true;

  // --- Getters Públicos para la UI ---

  User? get user => _user; // CORREGIDO: UserModel -> User
  bool get isLoading => _isLoading;
  bool get isAuth => _user != null;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = await FirestoreService.getUser(firebaseUser.uid);
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Métodos de Autenticación ---

  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      debugPrint('Login error: $error');
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String name, String phone,
      String role, String address) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final newUser = User(
          // CORREGIDO: UserModel -> User
          id: firebaseUser.uid,
          name: name,
          email: email,
          phone: phone,
          role: role,
          address: address, // Campo añadido
          createdAt: DateTime.now(),
        );
        await FirestoreService.createUser(newUser);
      }
    } catch (error) {
      debugPrint('Signup error: $error');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}