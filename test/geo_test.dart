import 'package:flutter_test/flutter_test.dart';
import 'package:nieves_rally/dominio/geo.dart';
import 'ayudas.dart';

void main() {
  test('ida y vuelta en 9 direcciones', () {
    for (final r in [0.0, 45, 90, 135, 180, 225, 270, 315, 359]) {
      final d = destino(origen, r.toDouble(), 250);
      expect(distanciaMetros(origen, d), closeTo(250, 0.05), reason: '$r');
      expect(giro(rumbo(origen, d), r.toDouble()).abs(), lessThan(0.05), reason: '$r');
    }
  });
  test('giro cruza el norte por el camino corto', () {
    expect(giro(10, 350), 20);
    expect(giro(350, 10), -20);
  });
  test('suavizar no se rompe en 350 -> 10', () {
    expect(suavizar(350, 10, alfa: 0.5), closeTo(0, 1e-9));
  });
  test('posX: centro, borde, fuera', () {
    expect(posX(0), 0.5);
    expect(posX(30), closeTo(1, 1e-9));
    expect(posX(31), isNull);
  });
}
