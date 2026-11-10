# Caza de Nieves AR (Dolores Hidalgo)
Version original del "Rally AR": atrapas 6 sabores de nieve escondidos alrededor del Jardin Principal.
Reglas: aparecen a 60-400 m, captura a <=20 m, 3 intentos (100/60/30 pts), al 3er fallo la nieve
se derrite y reaparece. Progreso guardado: solo ids y puntaje (nunca coordenadas).

## Pasos
1. `flutter create .`  (genera android/ e ios/; no pisa lib/ ni test/)
2. `flutter pub get && flutter test`
3. Android (AndroidManifest.xml): permisos CAMERA, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION; minSdk 21.
4. iOS (Info.plist): NSCameraUsageDescription y NSLocationWhenInUseUsageDescription.
5. `flutter run` -> "Modo demo" para jugar sin salir del salon.

Verifica las preguntas con heladeros/cronistas locales antes de usarlas en clase.
