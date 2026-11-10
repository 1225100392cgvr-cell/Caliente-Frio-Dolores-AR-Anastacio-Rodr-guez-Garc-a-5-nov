import 'package:flutter_test/flutter_test.dart';
import 'package:nieves_rally/dominio/aparicion.dart';
import 'package:nieves_rally/dominio/geo.dart';
import 'package:nieves_rally/dominio/partida.dart';
import 'package:nieves_rally/dominio/sabores.dart';
import 'ayudas.dart';

const _s = Sabor('x', 'X', '🍦', '', Pregunta('?', ['a', 'b', 'c'], 1));
Partida crear() =>
    Partida([Aparicion(_s, origen)], reubicar: () => const Coordenada(21.3, -100.8));

void main() {
  test('acierto al primer intento: 100 pts', () {
    final p = crear();
    expect((p.atrapar('x', 1, 10) as Atrapado).puntos, 100);
    expect(p.terminada, true);
  });
  test('lejos: no se puede intentar', () {
    expect(() => crear().atrapar('x', 1, 21), throwsA(isA<Lejos>()));
  });
  test('a exactamente 20 m cuenta', () {
    expect(crear().atrapar('x', 1, 20), isA<Atrapado>());
  });
  test('segundo intento 60, tercero 30', () {
    var p = crear()..atrapar('x', 0, 5);
    expect((p.atrapar('x', 1, 5) as Atrapado).puntos, 60);
    p = crear()..atrapar('x', 0, 5);
    p.atrapar('x', 2, 5);
    expect((p.atrapar('x', 1, 5) as Atrapado).puntos, 30);
  });
  test('tres fallos: se derrite y reaparece; el contador se reinicia', () {
    final p = crear();
    p.atrapar('x', 0, 5);
    expect((p.atrapar('x', 0, 5) as Fallo).quedan, 1);
    expect((p.atrapar('x', 0, 5) as Derritio).nueva.lat, 21.3);
    expect(p.atrapar('x', 0, 5), isA<Fallo>());
  });
  test('no se atrapa dos veces ni existe uno desconocido', () {
    final p = crear()..atrapar('x', 1, 5);
    expect(() => p.atrapar('x', 1, 5), throwsA(isA<YaAtrapado>()));
    expect(() => crear().atrapar('?', 0, 5), throwsA(isA<Desconocido>()));
  });
  test('restaurar ignora ids raros', () {
    final p = crear()..restaurar(['x', 'fantasma']);
    expect(p.atrapados, {'x'});
  });
}
