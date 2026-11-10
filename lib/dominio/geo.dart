import 'dart:math' as m;

class Coordenada {
  final double lat, lon;
  const Coordenada(this.lat, this.lon);
}

const _radioTierra = 6371000.0;
double _rad(double g) => g * m.pi / 180;
double _deg(double r) => r * 180 / m.pi;
double norm360(double g) => ((g % 360) + 360) % 360;

double distanciaMetros(Coordenada a, Coordenada b) {
  final dLat = _rad(b.lat - a.lat), dLon = _rad(b.lon - a.lon);
  final h = m.pow(m.sin(dLat / 2), 2) +
      m.cos(_rad(a.lat)) * m.cos(_rad(b.lat)) * m.pow(m.sin(dLon / 2), 2);
  return 2 * _radioTierra * m.asin(m.sqrt(h.clamp(0.0, 1.0).toDouble()));
}

double rumbo(Coordenada a, Coordenada b) {
  final dLon = _rad(b.lon - a.lon), p1 = _rad(a.lat), p2 = _rad(b.lat);
  final y = m.sin(dLon) * m.cos(p2);
  final x = m.cos(p1) * m.sin(p2) - m.sin(p1) * m.cos(p2) * m.cos(dLon);
  return norm360(_deg(m.atan2(y, x)));
}

/// Giro corto (-180..180) para ir de [actual] a [objetivo].
double giro(double objetivo, double actual) {
  final d = norm360(objetivo - actual);
  return d > 180 ? d - 360 : d;
}

double suavizar(double ant, double nuevo, {double alfa = 0.2}) =>
    norm360(ant + alfa * giro(nuevo, ant));

/// 0 = borde izquierdo, 1 = derecho, null = fuera de camara.
double? posX(double dif, {double fov = 60}) =>
    dif.abs() > fov / 2 ? null : 0.5 + dif / fov;

Coordenada destino(Coordenada o, double rbo, double metros) {
  final d = metros / _radioTierra, b = _rad(rbo);
  final p1 = _rad(o.lat), l1 = _rad(o.lon);
  final p2 = m.asin(m.sin(p1) * m.cos(d) + m.cos(p1) * m.sin(d) * m.cos(b));
  final l2 = l1 +
      m.atan2(m.sin(b) * m.sin(d) * m.cos(p1), m.cos(d) - m.sin(p1) * m.sin(p2));
  return Coordenada(_deg(p2), ((_deg(l2) + 540) % 360) - 180);
}
