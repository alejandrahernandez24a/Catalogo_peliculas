
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      await _authService.registrar(
        nombre: _nombreController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No fue posible crear la cuenta.';

      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado.';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es demasiado débil.';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo electrónico no es válido.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100D20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF100D20),
        foregroundColor: Colors.white,
        title: const Text('Crear cuenta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add_alt_1,
                    color: Color(0xFFB69AFF),
                    size: 85,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Únete a Catalogo de peliculas Alejandra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu nombre.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu correo.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                          .hasMatch(value.trim())) {
                        return 'Ingresa un correo válido.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_mostrarPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _mostrarPassword = !_mostrarPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Utiliza al menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _registrarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8055D8),
                        foregroundColor: Colors.white,
                      ),
                      child: _cargando
                          ? const CircularProgressIndicator()
                          : const Text('Registrarme'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
