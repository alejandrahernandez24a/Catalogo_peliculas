
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pelicula.dart';

class PeliculaService {
  final CollectionReference<Map<String, dynamic>> _coleccion =
      FirebaseFirestore.instance.collection('peliculas');

  // Consultar todas las películas en tiempo real.
  Stream<List<Pelicula>> obtenerPeliculas() {
    return _coleccion.orderBy('titulo').snapshots().map((snapshot) {
      return snapshot.docs.map((documento) {
        return Pelicula.fromMap(
          documento.id,
          documento.data(),
        );
      }).toList();
    });
  }

  // Registrar una película.
  Future<void> agregarPelicula(Pelicula pelicula) async {
    await _coleccion.add(pelicula.toMap());
  }

  // Consultar una película por su identificador.
  Future<Pelicula?> obtenerPelicula(String id) async {
    final documento = await _coleccion.doc(id).get();

    if (!documento.exists || documento.data() == null) {
      return null;
    }

    return Pelicula.fromMap(
      documento.id,
      documento.data()!,
    );
  }

  // Eliminar una película.
  Future<void> eliminarPelicula(String id) async {
    await _coleccion.doc(id).delete();
  }
}
