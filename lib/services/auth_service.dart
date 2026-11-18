
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener el usuario actual
  User? get usuarioActual => _auth.currentUser;

  // Escuchar cambios de sesión
  Stream<User?> get cambiosSesion => _auth.authStateChanges();

  // Registrar usuario
  Future<UserCredential> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Guardar información del usuario en Firestore
    await _db.collection('usuarios').doc(credencial.user!.uid).set({
      'nombre': nombre.trim(),
      'email': email.trim(),
      'rol': 'usuario',
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    return credencial;
  }

  // Iniciar sesión
  Future<UserCredential> iniciarSesion({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
 