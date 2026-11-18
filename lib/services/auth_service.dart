
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 
  User? get usuarioActual => _auth.currentUser;

 
  Stream<User?> get cambiosSesion => _auth.authStateChanges();

 
  Future<UserCredential> registrar({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

   
    await _db.collection('usuarios').doc(credencial.user!.uid).set({
      'nombre': nombre.trim(),
      'email': email.trim(),
      'rol': 'usuario',
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    return credencial;
  }

 
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
 