/// Solo guardamos ids y puntaje. NUNCA coordenadas (privacidad).
abstract class Almacen {
  Future<Set<String>> cargar();
  Future<void> guardar(Set<String> ids, int mejor);
  Future<int> mejor();
}

class AlmacenMemoria implements Almacen {
  Set<String> _ids = {};
  int _mejor = 0;
  @override
  Future<Set<String>> cargar() async => {..._ids};
  @override
  Future<void> guardar(Set<String> ids, int mejor) async {
    _ids = {...ids};
    if (mejor > _mejor) _mejor = mejor;
  }
  @override
  Future<int> mejor() async => _mejor;
}
