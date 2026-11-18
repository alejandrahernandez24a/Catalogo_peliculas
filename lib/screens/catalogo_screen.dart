
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pelicula.dart';
import '../services/auth_service.dart';
import '../services/pelicula_service.dart';
import 'detalle_pelicula_screen.dart';
import 'agregar_pelicula_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final PeliculaService _peliculaService = PeliculaService();
  final TextEditingController _buscador = TextEditingController();

  String _busqueda = '';

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  // Confirmar antes de eliminar una película.
  Future<void> _confirmarEliminacion(Pelicula pelicula) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar película'),
          content: Text(
            '¿Estás segura de que deseas eliminar "${pelicula.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _peliculaService.eliminarPelicula(pelicula.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película eliminada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar la película: $e'),
        ),
      );
    }
  }

  // Construir cada tarjeta del catálogo.
  Widget _tarjetaPelicula(Pelicula pelicula, bool esAdmin) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetallePeliculaScreen(
                      pelicula: pelicula,
                    ),
                  ),
                );
              },
              child: Image.network(
                pelicula.imagenUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white12,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 55,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Imagen no disponible',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    pelicula.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (esAdmin)
                  IconButton(
                    tooltip: 'Eliminar película',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () =>
                        _confirmarEliminacion(pelicula),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Text(
              '${pelicula.anio} · ${pelicula.genero}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return const Scaffold(
        body: Center(
          child: Text('No hay una sesión activa'),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .snapshots(),
      builder: (context, usuarioSnapshot) {
        if (usuarioSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (usuarioSnapshot.hasError || !usuarioSnapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Text(
                'No se pudo consultar el perfil del usuario',
              ),
            ),
          );
        }

        final datosUsuario = usuarioSnapshot.data!.data();
        final esAdmin = datosUsuario?['rol'] == 'admin';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Catálogo de películas Alejandra'),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await AuthService().cerrarSesion();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _buscador,
                  onChanged: (valor) {
                    setState(() {
                      _busqueda = valor.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar película...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _buscador.clear();
                        setState(() {
                          _busqueda = '';
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Pelicula>>(
                  stream: _peliculaService.obtenerPeliculas(),
                  builder: (context, peliculasSnapshot) {
                    if (peliculasSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (peliculasSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar películas: '
                          '${peliculasSnapshot.error}',
                        ),
                      );
                    }

                    final peliculas =
                        peliculasSnapshot.data ?? [];

                    final filtradas = peliculas.where((pelicula) {
                      return pelicula.titulo
                          .toLowerCase()
                          .contains(_busqueda);
                    }).toList();

                    if (filtradas.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay películas para mostrar',
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columnas =
                            constraints.maxWidth >= 900
                                ? 4
                                : constraints.maxWidth >= 600
                                    ? 3
                                    : 2;

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columnas,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.62,
                          ),
                          itemCount: filtradas.length,
                          itemBuilder: (context, index) {
                            return _tarjetaPelicula(
                              filtradas[index],
                              esAdmin,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: esAdmin
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AgregarPeliculaScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar película'),
                )
              : null,
        );
      },
    );
  }
}
