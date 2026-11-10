import 'dart:math' as m;
import 'aparicion.dart';
import 'geo.dart';

/// (x,y) en -1..1, arriba = hacia donde miras. null si esta fuera de alcance.
(double, double)? puntoRadar(Coordenada yo, double mirando, Coordenada obj,
    {double alcance = 500}) {
  final d = distanciaMetros(yo, obj);
  if (d > alcance) return null;
  final a = giro(rumbo(yo, obj), mirando) * m.pi / 180, f = d / alcance;
  return (f * m.sin(a), -f * m.cos(a));
}

enum Temp { helado, frio, tibio, caliente, ardiente }

Temp temperatura(double metros) {
  if (metros <= 20) return Temp.ardiente;
  if (metros <= 60) return Temp.caliente;
  if (metros <= 150) return Temp.tibio;
  if (metros <= 300) return Temp.frio;
  return Temp.helado;
}

String textoTemp(Temp t) => switch (t) {
      Temp.helado => '🧊 Helado',
      Temp.frio => '❄️ Frio',
      Temp.tibio => '🌤️ Tibio',
      Temp.caliente => '🔥 Caliente',
      Temp.ardiente => '🍦 ¡Ahi esta! Tocalo',
    };

class Visible {
  final Aparicion ap;
  final double dist, x, prof, escala;
  const Visible(this.ap, this.dist, this.x, this.prof, this.escala);
}

List<Visible> visibles(Coordenada yo, double mirando, Iterable<Aparicion> aps,
    {double fov = 60, double maxM = 500}) {
  final r = <Visible>[];
  for (final a in aps) {
    final d = distanciaMetros(yo, a.pos);
    if (d > maxM) continue;
    final x = posX(giro(rumbo(yo, a.pos), mirando), fov: fov);
    if (x == null) continue;
    final p = d / maxM;
    r.add(Visible(a, d, x, p, 1.2 - 0.6 * p));
  }
  r.sort((a, b) => b.dist.compareTo(a.dist));
  return r;
}
