import 'dart:async';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';

class PosicionDemo implements FuentePosicion {
  Coordenada _c;
  final _s = StreamController<Coordenada>.broadcast();
  PosicionDemo(this._c);
  @override
  Stream<Coordenada> get posiciones async* {
    yield _c;
    yield* _s.stream;
  }
  void caminar(double rbo, double m) {
    _c = m >= 0 ? destino(_c, rbo, m) : destino(_c, rbo + 180, -m);
    _s.add(_c);
  }
}

class BrujulaDemo implements FuenteBrujula {
  final _s = StreamController<double>.broadcast();
  double _u = 0;
  @override
  Stream<double> get rumbos async* {
    yield _u;
    yield* _s.stream;
  }
  void girar(double g) {
    _u = g;
    _s.add(g);
  }
}
