
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/inicio_screen.dart';
import 'screens/catalogo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CatalogoPeliculas());
}

class CatalogoPeliculas extends StatelessWidget {
  const CatalogoPeliculas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo de películas Alejandra',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF100D20),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8055D8),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          prefixIconColor: Color(0xFFB69AFF),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFB69AFF),
              width: 2,
            ),
          ),
        ),
      ),
      home: const ControlSesion(),
    );
  }
}

class ControlSesion extends StatelessWidget {
  const ControlSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().cambiosSesion,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const CatalogoScreen();
        }

        return const InicioScreen();
      },
    );
  }
}
