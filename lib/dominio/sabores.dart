import 'geo.dart';

/// Centro del juego: Jardin Principal de Dolores Hidalgo (aproximado).
const plaza = Coordenada(21.15610, -100.93180);

class Pregunta {
  final String texto;
  final List<String> opciones;
  final int correcta;
  const Pregunta(this.texto, this.opciones, this.correcta);
}

class Sabor {
  final String id, nombre, emoji, dato;
  final Pregunta pregunta;
  const Sabor(this.id, this.nombre, this.emoji, this.dato, this.pregunta);
}

/// VERIFICA estos datos con heladeros/cronistas locales antes de usar en clase.
const sabores = <Sabor>[
  Sabor('aguacate', 'Nieve de aguacate', '🥑',
      'Un clasico de las nieves exoticas: cremosa y suave.',
      Pregunta('¿De que fruta se hace la nieve de aguacate?',
          ['Mango', 'Aguacate', 'Limon'], 1)),
  Sabor('limon', 'Nieve de limon', '🍋',
      'Muchas nieves de agua llevan solo fruta, agua y azucar.',
      Pregunta('¿Cual es un ingrediente basico de una nieve de agua?',
          ['Fruta', 'Aceite', 'Harina'], 0)),
  Sabor('tuna', 'Nieve de tuna', '🌵', 'La tuna es el fruto del nopal.',
      Pregunta('¿De que planta es fruto la tuna?', ['Maguey', 'Nopal', 'Maiz'], 1)),
  Sabor('chocolate', 'Nieve de chocolate', '🍫',
      'El cacao tiene origen mesoamericano.',
      Pregunta('¿De que semilla se obtiene el chocolate?',
          ['Cafe', 'Vainilla', 'Cacao'], 2)),
  Sabor('fresa', 'Nieve de fresa', '🍓', 'Dulce y ligera, ideal para la tarde.',
      Pregunta('¿De que color es una fresa madura?', ['Roja', 'Azul', 'Negra'], 0)),
  Sabor('coco', 'Nieve de coco', '🥥',
      'El coco crece en palmeras de zonas costeras.',
      Pregunta('¿En que tipo de arbol crece el coco?',
          ['Encino', 'Pino', 'Palmera'], 2)),
];
