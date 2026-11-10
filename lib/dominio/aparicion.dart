import 'dart:math' as m;
import 'geo.dart';
import 'sabores.dart';

class Aparicion {
  final Sabor sabor;
  final Coordenada pos;
  const Aparicion(this.sabor, this.pos);
}

/// Distribucion uniforme por AREA en un anillo (de ahi la raiz cuadrada).
Coordenada puntoEnAnillo(Coordenada c, double rMin, double rMax, m.Random r) {
  final d = m.sqrt(rMin * rMin + r.nextDouble() * (rMax * rMax - rMin * rMin));
  return destino(c, r.nextDouble() * 360, d);
}

List<Aparicion> esconder(Coordenada centro, List<Sabor> lista, m.Random random,
        {double rMin = 60, double rMax = 400}) =>
    [for (final s in lista) Aparicion(s, puntoEnAnillo(centro, rMin, rMax, random))];
