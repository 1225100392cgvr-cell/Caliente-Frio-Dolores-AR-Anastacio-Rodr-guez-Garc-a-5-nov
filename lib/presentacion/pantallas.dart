import 'dart:math' as m;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../datos/fuentes_demo.dart';
import '../datos/fuentes_reales.dart';
import '../dominio/almacen.dart';
import '../dominio/partida.dart';
import '../dominio/radar.dart';
import '../dominio/sabores.dart';
import 'vm.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});
  void _ir(BuildContext c, RallyVm Function() f, [PosicionDemo? p, BrujulaDemo? b]) =>
      Navigator.push(c, MaterialPageRoute<void>(builder: (_) => Juego(f, p, b)));

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Caza de Nieves AR')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text('Atrapa los 6 sabores escondidos en Dolores Hidalgo',
              style: Theme.of(c).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Usa el radar y el frio/caliente. A 20 m o menos, tocalo y responde.'),
          Card(
              color: Colors.amber.shade100,
              child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('⚠️ Mira a tu alrededor y no cruces la calle viendo el telefono.'))),
          FilledButton(
              onPressed: () => _ir(c,
                  () => RallyVm(PosicionGps(), BrujulaReal(), AlmacenPrefs(), m.Random())),
              child: const Text('Jugar con GPS real')),
          OutlinedButton(
              onPressed: () {
                final p = PosicionDemo(plaza);
                final b = BrujulaDemo();
                _ir(c, () => RallyVm(p, b, AlmacenMemoria(), m.Random()), p, b);
              },
              child: const Text('Modo demo (salon de clases)')),
        ]),
      );
}

class Juego extends StatefulWidget {
  final RallyVm Function() crear;
  final PosicionDemo? p;
  final BrujulaDemo? b;
  const Juego(this.crear, this.p, this.b, {super.key});
  @override
  State<Juego> createState() => _JuegoState();
}

class _JuegoState extends State<Juego> {
  late final RallyVm vm = widget.crear();
  double _g = 0;
  CameraController? _cam;

  @override
  void initState() {
    super.initState();
    vm.iniciar();
    _camara();
  }

  Future<void> _camara() async {
    try {
      final cs = await availableCameras();
      final c = CameraController(cs.first, ResolutionPreset.medium, enableAudio: false);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _cam = c);
    } catch (_) {}
  }

  @override
  void dispose() {
    _cam?.dispose();
    vm.dispose();
    super.dispose();
  }

  void _aviso(String t) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(t), duration: const Duration(seconds: 3)));

  Future<void> _tocar(Visible v) async {
    final s = v.ap.sabor;
    if (v.dist > Partida.radio) return _aviso(Lejos(v.dist).toString());
    final o = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (_) => SimpleDialog(title: Text('${s.emoji} ${s.pregunta.texto}'), children: [
              for (var i = 0; i < s.pregunta.opciones.length; i++)
                SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, i),
                    child: Text(s.pregunta.opciones[i]))
            ]));
    if (o == null) return;
    try {
      switch (await vm.atrapar(s.id, o)) {
        case Atrapado(:final puntos):
          _aviso('🎉 ${s.nombre} +$puntos\n${s.dato}');
        case Fallo(:final quedan):
          _aviso('❌ Incorrecto. Quedan $quedan intentos.');
        case Derritio():
          _aviso('💧 ¡Se derritio! Buscalo en otro lugar.');
      }
    } catch (e) {
      _aviso(mensajeSeguro(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AnimatedBuilder(
          animation: vm,
          builder: (_, __) => LayoutBuilder(
            builder: (_, box) => Stack(fit: StackFit.expand, children: [
              if (_cam?.value.isInitialized ?? false)
                CameraPreview(_cam!)
              else
                const DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF3B1E54), Color(0xFFD97B66), Color(0xFFF4D58D)]))),
              for (final v in vm.vis)
                Positioned(
                  left: v.x * box.maxWidth - 45,
                  top: box.maxHeight * (0.5 - 0.28 * v.prof),
                  width: 90,
                  child: Transform.scale(
                    scale: v.escala,
                    child: GestureDetector(
                      onTap: () => _tocar(v),
                      child: Column(children: [
                        CircleAvatar(
                            radius: 36,
                            backgroundColor: v.dist <= Partida.radio
                                ? Colors.lightGreenAccent
                                : Colors.white70,
                            child: Text(v.ap.sabor.emoji, style: const TextStyle(fontSize: 38))),
                        Text(v.dist <= Partida.radio ? '¡Tocame!' : '${v.dist.round()} m',
                            style: const TextStyle(
                                color: Colors.white, backgroundColor: Colors.black54)),
                      ]),
                    ),
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: vm.error != null ? Colors.red.shade800 : Colors.black54,
                      child: Text(
                          vm.error ??
                              (vm.esperando
                                  ? 'Buscando GPS y brujula…'
                                  : '🍨 ${vm.partida.atrapados.length}/${sabores.length} · ${vm.partida.puntos} pts\n'
                                      '${vm.temp == null ? "¡Completaste el album!" : textoTemp(vm.temp!)}'),
                          style: const TextStyle(color: Colors.white)),
                    ),
                    const Spacer(),
                    SizedBox(
                        width: 110,
                        height: 110,
                        child: CustomPaint(painter: _Radar(vm.radar))),
                  ]),
                ),
              ),
              if (widget.p != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Container(
                      color: Colors.black54,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Slider(
                            min: 0,
                            max: 359,
                            value: _g,
                            onChanged: (g) {
                              setState(() => _g = g);
                              widget.b!.girar(g);
                            }),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                          OutlinedButton(
                              onPressed: () => widget.p!.caminar(_g, -10),
                              child: const Text('Atras 10')),
                          FilledButton(
                              onPressed: () => widget.p!.caminar(_g, 10),
                              child: const Text('Avanzar 10')),
                          OutlinedButton(
                              onPressed: () => widget.p!.caminar(_g, 2),
                              child: const Text('+2 m')),
                        ]),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      );
}

class _Radar extends CustomPainter {
  final List<(double, double)> pts;
  _Radar(this.pts);
  @override
  void paint(Canvas c, Size s) {
    final o = s.center(Offset.zero), r = s.width / 2;
    c.drawCircle(o, r, Paint()..color = Colors.black54);
    final l = Paint()
      ..color = Colors.lightGreenAccent
      ..style = PaintingStyle.stroke;
    c.drawCircle(o, r, l);
    c.drawCircle(o, r / 2, l);
    c.drawCircle(o, 4, Paint()..color = Colors.white);
    for (final (x, y) in pts) {
      c.drawCircle(Offset(o.dx + x * (r - 6), o.dy + y * (r - 6)), 5,
          Paint()..color = Colors.orangeAccent);
    }
  }

  @override
  bool shouldRepaint(_Radar v) => true;
}
