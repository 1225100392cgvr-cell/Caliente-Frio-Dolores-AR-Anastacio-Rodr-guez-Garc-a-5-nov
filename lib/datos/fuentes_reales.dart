import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dominio/almacen.dart';
import '../dominio/fuentes.dart';
import '../dominio/geo.dart';
import '../dominio/partida.dart';

class PosicionGps implements FuentePosicion {
  @override
  Stream<Coordenada> get posiciones async* {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ErrorJuego('El GPS esta apagado. Activalo para jugar.');
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
      throw const ErrorJuego('Necesito el permiso de ubicacion. Activalo en Ajustes.');
    }
    yield* Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 2),
    ).map((x) => Coordenada(x.latitude, x.longitude));
  }
}

class BrujulaReal implements FuenteBrujula {
  @override
  Stream<double> get rumbos {
    final e = FlutterCompass.events;
    if (e == null) {
      return Stream.error(const ErrorJuego('Sin brujula: usa el modo demo.'));
    }
    return e.where((v) => v.heading != null).map((v) => norm360(v.heading!));
  }
}

class AlmacenPrefs implements Almacen {
  @override
  Future<Set<String>> cargar() async =>
      ((await SharedPreferences.getInstance()).getStringList('ids') ?? []).toSet();
  @override
  Future<void> guardar(Set<String> ids, int mejor) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('ids', ids.toList());
    if (mejor > (p.getInt('mejor') ?? 0)) await p.setInt('mejor', mejor);
  }
  @override
  Future<int> mejor() async => (await SharedPreferences.getInstance()).getInt('mejor') ?? 0;
}
