
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/tmdb_config.dart';

class CatalogoApiService {
  static const String _baseUrl =
      'https://api.themoviedb.org/3';

  static const String _imageBaseUrl =
      'https://image.tmdb.org/t/p/w500';

  Map<String, String> get _headers {
    final token = TmdbConfig.bearerToken;

    if (token.isEmpty) {
      throw Exception(
        'No se configuró el API Read Access Token de TMDB.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>?> buscarPelicula(
    String titulo,
  ) async {
    final termino = titulo.trim();

    if (termino.isEmpty) {
      throw Exception('Escribe el título de una película.');
    }

    // 1. Buscar la película en TMDB.
    final urlBusqueda = Uri.parse(
      '$_baseUrl/search/movie',
    ).replace(
      queryParameters: {
        'query': termino,
        'language': 'es-MX',
        'include_adult': 'false',
        'page': '1',
      },
    );

    print('CONSULTA TMDB: $urlBusqueda');

    final respuestaBusqueda = await http
        .get(urlBusqueda, headers: _headers)
        .timeout(const Duration(seconds: 20));

    print(
      'ESTADO BUSQUEDA: ${respuestaBusqueda.statusCode}',
    );

    if (respuestaBusqueda.statusCode != 200) {
      throw Exception(
        'Error al buscar película en TMDB: '
        '${respuestaBusqueda.statusCode} '
        '${respuestaBusqueda.body}',
      );
    }

    final datosBusqueda = jsonDecode(
      utf8.decode(respuestaBusqueda.bodyBytes),
    ) as Map<String, dynamic>;

    final resultados = datosBusqueda['results'] as List? ?? [];

    print('PELÍCULAS ENCONTRADAS: ${resultados.length}');

    if (resultados.isEmpty) {
      return null;
    }

    // 2. Obtener el identificador de la primera coincidencia.
    final primeraPelicula =
        resultados.first as Map<String, dynamic>;

    final id = primeraPelicula['id'];

    if (id == null) {
      throw Exception('TMDB no devolvió el ID de la película.');
    }

    // 3. Consultar detalles y créditos.
    final urlDetalle = Uri.parse(
      '$_baseUrl/movie/$id',
    ).replace(
      queryParameters: {
        'language': 'es-MX',
        'append_to_response': 'credits',
      },
    );

    final respuestaDetalle = await http
        .get(urlDetalle, headers: _headers)
        .timeout(const Duration(seconds: 20));

    print('ESTADO DETALLE: ${respuestaDetalle.statusCode}');

    if (respuestaDetalle.statusCode != 200) {
      throw Exception(
        'No se pudieron obtener los detalles: '
        '${respuestaDetalle.statusCode}',
      );
    }

    final pelicula = jsonDecode(
      utf8.decode(respuestaDetalle.bodyBytes),
    ) as Map<String, dynamic>;

    // 4. Obtener el director desde los créditos.
    final creditos = pelicula['credits'] as Map<String, dynamic>?;

    final equipo = creditos?['crew'] as List? ?? [];

    final director = equipo.cast<Map<String, dynamic>>()
        .where((persona) => persona['job'] == 'Director')
        .map((persona) => persona['name']?.toString() ?? '')
        .where((nombre) => nombre.isNotEmpty)
        .join(', ');

    // 5. Obtener los géneros.
    final generos = pelicula['genres'] as List? ?? [];

    final genero = generos
        .map((elemento) =>
            (elemento as Map<String, dynamic>)['name'] ?? '')
        .where((nombre) => nombre.toString().isNotEmpty)
        .join(', ');

    // 6. Construir la URL del póster.
    final posterPath = pelicula['poster_path'];

    final imagenUrl = posterPath != null
        ? '$_imageBaseUrl$posterPath'
        : '';

    // 7. Obtener el año de estreno.
    final fecha = DateTime.tryParse(
      pelicula['release_date']?.toString() ?? '',
    );

    return {
      'titulo': pelicula['title'] ?? '',
      'anio': fecha?.year ?? 0,
      'director': director,
      'genero': genero,
      'sinopsis': pelicula['overview'] ?? '',
      'imagenUrl': imagenUrl,
    };
  }
}
