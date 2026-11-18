
import 'package:flutter/material.dart';

import '../models/pelicula.dart';
import '../services/pelicula_service.dart';
import '../services/catalogo_api_service.dart';

class AgregarPeliculaScreen extends StatefulWidget {
  const AgregarPeliculaScreen({super.key});

  @override
  State<AgregarPeliculaScreen> createState() =>
      _AgregarPeliculaScreenState();
}

class _AgregarPeliculaScreenState
    extends State<AgregarPeliculaScreen> {

  // Controladores del formulario
  final _formKey = GlobalKey<FormState>();

  final _consultaApi = TextEditingController();
  final _titulo = TextEditingController();
  final _anio = TextEditingController();
  final _director = TextEditingController();
  final _genero = TextEditingController();
  final _sinopsis = TextEditingController();
  final _imagenUrl = TextEditingController();

  // Estados de carga
  bool _guardando = false;
  bool _buscandoApi = false;

  // Liberar controladores
  @override
  void dispose() {
    _consultaApi.dispose();
    _titulo.dispose();
    _anio.dispose();
    _director.dispose();
    _genero.dispose();
    _sinopsis.dispose();
    _imagenUrl.dispose();
    super.dispose();
  }

  // Buscar información mediante HTTP
  Future<void> _buscarPeliculaInternet() async {
  final termino = _consultaApi.text.trim();

  if (termino.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Escribe el título de una película'),
      ),
    );
    return;
  }

  setState(() {
    _buscandoApi = true;
  });

  try {
    final pelicula =
        await CatalogoApiService().buscarPelicula(termino);

    if (!mounted) return;

    if (pelicula != null) {
      setState(() {
        _titulo.text = pelicula['titulo']?.toString() ?? '';
        _anio.text = pelicula['anio']?.toString() ?? '';
        _director.text = pelicula['director']?.toString() ?? '';
        _genero.text = pelicula['genero']?.toString() ?? '';
        _sinopsis.text = pelicula['sinopsis']?.toString() ?? '';
        _imagenUrl.text = pelicula['imagenUrl']?.toString() ?? '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película encontrada en TMDB'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron películas con ese título'),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al buscar película: $e'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _buscandoApi = false;
      });
    }
  }
}

  // Guardar película en Firestore
  Future<void> _guardarPelicula() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      final pelicula = Pelicula(
        titulo: _titulo.text.trim(),
        anio: int.parse(_anio.text.trim()),
        director: _director.text.trim(),
        genero: _genero.text.trim(),
        sinopsis: _sinopsis.text.trim(),
        imagenUrl: _imagenUrl.text.trim(),
      );

      await PeliculaService().agregarPelicula(pelicula);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película registrada correctamente'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo registrar la película: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // Campo reutilizable del formulario
  Widget _campo({
    required String etiqueta,
    required TextEditingController controlador,
    int maxLineas = 1,
    TextInputType? tipo,
    String? Function(String?)? validador,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controlador,
        maxLines: maxLineas,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
        validator: validador ??
            (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
      ),
    );
  }

  // Construcción de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar película'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // Búsqueda externa
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Buscar información en internet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _consultaApi,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la película',
                      hintText: 'Ej. Interstellar',
                      prefixIcon: Icon(Icons.travel_explore),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _buscandoApi
                          ? null
                          : _buscarPeliculaInternet,
                      icon: const Icon(Icons.search),
                      label: Text(
                        _buscandoApi
                            ? 'Buscando...'
                            : 'Consultar información',
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Información de la película',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datos de la película
                  _campo(
                    etiqueta: 'Título',
                    controlador: _titulo,
                  ),

                  _campo(
                    etiqueta: 'Año',
                    controlador: _anio,
                    tipo: TextInputType.number,
                    validador: (valor) {
                      final anio = int.tryParse(valor?.trim() ?? '');

                      if (anio == null || anio < 1888 || anio > 2100) {
                        return 'Ingresa un año válido';
                      }

                      return null;
                    },
                  ),

                  _campo(
                    etiqueta: 'Director',
                    controlador: _director,
                  ),

                  _campo(
                    etiqueta: 'Género',
                    controlador: _genero,
                  ),

                  _campo(
                    etiqueta: 'Sinopsis',
                    controlador: _sinopsis,
                    maxLineas: 4,
                  ),

                  _campo(
                    etiqueta: 'URL de la imagen del póster',
                    controlador: _imagenUrl,
                    tipo: TextInputType.url,
                    validador: (valor) {
                      final uri = Uri.tryParse(valor?.trim() ?? '');

                      if (uri == null ||
                          !uri.hasScheme ||
                          !['http', 'https'].contains(uri.scheme) ||
                          uri.host.isEmpty) {
                        return 'Ingresa una URL válida';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Guardar en Firestore
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardando
                          ? null
                          : _guardarPelicula,
                      icon: const Icon(Icons.save),
                      label: Text(
                        _guardando
                            ? 'Guardando...'
                            : 'Guardar película',
                      ),
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
