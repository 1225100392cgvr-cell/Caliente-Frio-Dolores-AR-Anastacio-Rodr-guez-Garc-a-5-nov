import 'aparicion.dart';
import 'geo.dart';

class ErrorJuego implements Exception {
  final String mensaje;
  const ErrorJuego(this.mensaje);
  @override
  String toString() => mensaje;
}

class Lejos extends ErrorJuego {
  Lejos(double m) : super('Estas a ${m.round()} m. Acercate a ${Partida.radio.round()} m.');
}

class YaAtrapado extends ErrorJuego {
  const YaAtrapado() : super('Ese sabor ya esta en tu album.');
}

class Desconocido extends ErrorJuego {
  const Desconocido() : super('Ese sabor no existe.');
}

String mensajeSeguro(Object e) =>
    e is ErrorJuego ? e.toString() : 'Ocurrio un error inesperado.';

sealed class Resultado {}

class Atrapado extends Resultado {
  final int puntos;
  Atrapado(this.puntos);
}

class Fallo extends Resultado {
  final int quedan;
  Fallo(this.quedan);
}

class Derritio extends Resultado {
  final Coordenada nueva;
  Derritio(this.nueva);
}

/// Reglas: 20 m, 3 intentos (100/60/30 pts). Al 3er fallo la nieve "se derrite"
/// y reaparece en otro lugar.
class Partida {
  static const double radio = 20;
  static const maxFallos = 3;
  static const premios = [100, 60, 30];

  final Map<String, Aparicion> _aps;
  final Coordenada Function() _reubicar;
  final Set<String> _ok = {};
  final Map<String, int> _fallos = {};
  int puntos = 0;

  Partida(List<Aparicion> aps, {required Coordenada Function() reubicar})
      : _aps = {for (final a in aps) a.sabor.id: a},
        _reubicar = reubicar;

  List<Aparicion> get todas => _aps.values.toList();
  List<Aparicion> get pendientes =>
      _aps.values.where((a) => !_ok.contains(a.sabor.id)).toList();
  Set<String> get atrapados => Set.unmodifiable(_ok);
  bool get terminada => _ok.length == _aps.length;

  void restaurar(Iterable<String> ids) => _ok.addAll(ids.where(_aps.containsKey));

  Resultado atrapar(String id, int opcion, double metros) {
    final a = _aps[id];
    if (a == null) throw const Desconocido();
    if (_ok.contains(id)) throw const YaAtrapado();
    if (metros > radio) throw Lejos(metros);
    final previos = _fallos[id] ?? 0;
    if (opcion == a.sabor.pregunta.correcta) {
      _ok.add(id);
      puntos += premios[previos];
      return Atrapado(premios[previos]);
    }
    final f = previos + 1;
    if (f >= maxFallos) {
      _fallos[id] = 0;
      final n = _reubicar();
      _aps[id] = Aparicion(a.sabor, n);
      return Derritio(n);
    }
    _fallos[id] = f;
    return Fallo(maxFallos - f);
  }
}
