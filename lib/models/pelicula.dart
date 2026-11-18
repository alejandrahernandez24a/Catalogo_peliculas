
class Pelicula {
  final String id;
  final String titulo;
  final int anio;
  final String director;
  final String genero;
  final String sinopsis;
  final String imagenUrl;

  Pelicula({
    this.id = '',
    required this.titulo,
    required this.anio,
    required this.director,
    required this.genero,
    required this.sinopsis,
    required this.imagenUrl,
  });

 
  factory Pelicula.fromMap(String id, Map<String, dynamic> data) {
    return Pelicula(
      id: id,
      titulo: data['titulo'] ?? '',
      anio: (data['anio'] as num?)?.toInt() ?? 0,
      director: data['director'] ?? '',
      genero: data['genero'] ?? '',
      sinopsis: data['sinopsis'] ?? '',
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }

 
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'anio': anio,
      'director': director,
      'genero': genero,
      'sinopsis': sinopsis,
      'imagenUrl': imagenUrl,
    };
  }
}
