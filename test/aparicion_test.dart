import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:nieves_rally/dominio/aparicion.dart';
import 'package:nieves_rally/dominio/geo.dart';
import 'package:nieves_rally/dominio/sabores.dart';
import 'ayudas.dart';

void main() {
  test('uno por sabor y dentro del anillo', () {
    final a = esconder(origen, sabores, Random(7));
    expect(a.length, sabores.length);
    for (final x in a) {
      expect(distanciaMetros(origen, x.pos), inInclusiveRange(59.9, 400.1));
    }
  });
  test('misma semilla = mismo resultado', () {
    final a = esconder(origen, sabores, Random(42));
    final b = esconder(origen, sabores, Random(42));
    for (var i = 0; i < a.length; i++) {
      expect(a[i].pos.lat, b[i].pos.lat);
    }
  });
  test('se reparten por todos los cuadrantes', () {
    final r = Random(5);
    final rb = [for (var i = 0; i < 400; i++) rumbo(origen, puntoEnAnillo(origen, 60, 400, r))];
    for (final q in [0, 90, 180, 270]) {
      expect(rb.where((g) => g >= q && g < q + 90).length, greaterThan(60));
    }
  });
}
