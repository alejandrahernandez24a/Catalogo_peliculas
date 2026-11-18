
import 'package:flutter/material.dart';
import '../models/pelicula.dart';

class DetallePeliculaScreen extends StatelessWidget {
  final Pelicula pelicula;

  const DetallePeliculaScreen({
    super.key,
    required this.pelicula,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de película'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  pelicula.imagenUrl,
                  height: 350,
                  width: 240,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 350,
                      width: 240,
                      color: Colors.white12,
                      child: const Icon(
                        Icons.movie,
                        size: 80,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              pelicula.titulo,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _dato('Año', pelicula.anio.toString()),
            _dato('Director', pelicula.director),
            _dato('Género', pelicula.genero),
            const SizedBox(height: 20),
            const Text(
              'Sinopsis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pelicula.sinopsis,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$etiqueta:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFB69AFF),
              ),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
