import 'package:flutter/material.dart';
import 'presentacion/pantallas.dart';

void main() => runApp(MaterialApp(
      title: 'Caza de Nieves AR',
      theme: ThemeData(colorSchemeSeed: Colors.pink, useMaterial3: true),
      home: const Inicio(),
    ));
