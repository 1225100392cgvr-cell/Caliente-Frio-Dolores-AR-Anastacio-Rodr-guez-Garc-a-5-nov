import 'dart:async';
import 'dart:math' as m;
import 'package:flutter/foundation.dart';
import '../dominio/almacen.dart';
import '../dominio/aparicion.dart';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';
import '../dominio/partida.dart';
import '../dominio/radar.dart';
import '../dominio/sabores.dart';

class RallyVm extends ChangeNotifier {
  final FuentePosicion _gps;
  final FuenteBrujula _bru;
  final Almacen almacen;
  late final Partida partida;
  Coordenada? yo;
  double? mirando;
  List<Visible> vis = [];
  String? error;
  StreamSubscription<Coordenada>? _a;
  StreamSubscription<double>? _b;

  RallyVm(this._gps, this._bru, this.almacen, m.Random random,
      {Coordenada centro = plaza}) {
    partida = Partida(esconder(centro, sabores, random),
        reubicar: () => puntoEnAnillo(centro, 60, 400, random));
  }

  bool get esperando => yo == null || mirando == null;

  Aparicion? get cercano {
    final u = yo;
    final p = partida.pendientes;
    if (u == null || p.isEmpty) return null;
    p.sort((a, b) => distanciaMetros(u, a.pos).compareTo(distanciaMetros(u, b.pos)));
    return p.first;
  }

  Temp? get temp =>
      cercano == null ? null : temperatura(distanciaMetros(yo!, cercano!.pos));

  List<(double, double)> get radar {
    if (esperando) return const [];
    return [
      for (final a in partida.pendientes)
        if (puntoRadar(yo!, mirando!, a.pos) case final p?) p
    ];
  }

  Future<void> iniciar() async {
    partida.restaurar(await almacen.cargar());
    _a = _gps.posiciones.listen((p) {
      yo = p;
      _calc();
    }, onError: _fallo);
    _b = _bru.rumbos.listen((g) {
      mirando = mirando == null ? g : suavizar(mirando!, g);
      _calc();
    }, onError: _fallo);
    notifyListeners();
  }

  void _fallo(Object e) {
    error = mensajeSeguro(e);
    notifyListeners();
  }

  void _calc() {
    if (!esperando) vis = visibles(yo!, mirando!, partida.pendientes);
    notifyListeners();
  }

  Future<Resultado> atrapar(String id, int opcion) async {
    final a = partida.todas.where((x) => x.sabor.id == id).firstOrNull;
    final d = (yo == null || a == null) ? double.infinity : distanciaMetros(yo!, a.pos);
    final r = partida.atrapar(id, opcion, d);
    if (r is Atrapado) await almacen.guardar(partida.atrapados, partida.puntos);
    _calc();
    return r;
  }

  @override
  void dispose() {
    _a?.cancel();
    _b?.cancel();
    super.dispose();
  }
}
