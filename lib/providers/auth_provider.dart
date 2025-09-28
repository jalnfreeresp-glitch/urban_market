import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
// Se añade alias para consistencia
import 'package:urban_market/models/user_model.dart' as um;
import 'package:urban_market/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  um.UserModel? _user;
  bool _isLoading = true;

  // --- Getters ---
  um.UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuth => _user != null;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(fb_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      // Se obtiene el usuario de Firestore
      _user = await _firestoreService.getUser(firebaseUser.uid);
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Métodos ---
  Future<String?> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null; // Éxito
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.message}');
      return e.message; // Devuelve el mensaje de error para la UI
    }
  }

  Future<String?> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'Cliente', // Rol por defecto
    String? address,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final newUser = um.UserModel(
          id: firebaseUser.uid,
          name: name,
          email: email,
          phone: phone,
          role: role,
          address: address,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(newUser);
      }
      return null; // Éxito
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint('Signup error: ${e.message}');
      return e.message; // Devuelve el mensaje de error para la UI
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
