
import 'package:flutter_test/flutter_test.dart';
import 'package:catalogo_peliculas/main.dart';

void main() {
  testWidgets('La aplicación tiene el nombre correcto',
      (WidgetTester tester) async {
    expect(CatalogoPeliculas, isNotNull);
  });
}