import 'package:flutter_test/flutter_test.dart';
import 'package:nieves_rally/dominio/aparicion.dart';
import 'package:nieves_rally/dominio/geo.dart';
import 'package:nieves_rally/dominio/radar.dart';
import 'package:nieves_rally/dominio/sabores.dart';
import 'ayudas.dart';

Aparicion en(double r, double m) => Aparicion(sabores.first, destino(origen, r, m));

void main() {
  final n = destino(origen, 0, 250);
  final e = destino(origen, 90, 250);
  final s = destino(origen, 180, 250);

  test('orientacion del radar', () {
    final p = puntoRadar(origen, 0, n)!;
    expect(p.$1, closeTo(0, 0.01));
    expect(p.$2, closeTo(-0.5, 0.01));
    expect(puntoRadar(origen, 0, e)!.$1, closeTo(0.5, 0.01));
    expect(puntoRadar(origen, 90, e)!.$2, closeTo(-0.5, 0.01));
    expect(puntoRadar(origen, 0, s)!.$2, closeTo(0.5, 0.01));
    expect(puntoRadar(origen, 0, destino(origen, 0, 800)), isNull);
  });
  test('umbrales de temperatura', () {
    expect(temperatura(20), Temp.ardiente);
    expect(temperatura(40), Temp.caliente);
    expect(temperatura(100), Temp.tibio);
    expect(temperatura(250), Temp.frio);
    expect(temperatura(500), Temp.helado);
  });
  test('mas lejos nunca es mas caliente', () {
    var anterior = Temp.ardiente.index;
    for (var m = 0.0; m <= 1000; m += 5) {
      final i = temperatura(m).index;
      expect(i, lessThanOrEqualTo(anterior));
      anterior = i;
    }
  });
  test('visibles: centro, fuera de campo, cruce del norte, orden', () {
    expect(visibles(origen, 0, [en(0, 100)]).single.x, closeTo(0.5, 0.01));
    expect(visibles(origen, 90, [en(0, 100)]), isEmpty);
    expect(visibles(origen, 350, [en(5, 100)]).single.x, greaterThan(0.5));
    final v = visibles(origen, 0, [en(0, 40), en(0, 450)]);
    expect(v.first.dist, greaterThan(v.last.dist));
    expect(v.last.escala, greaterThan(v.first.escala));
  });
}
