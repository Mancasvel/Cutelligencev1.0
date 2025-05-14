import 'face_shape.dart';

class HaircutStyle {
  final String name;
  final String description;
  final String imageUrl;
  final List<FaceShape> suitableFaceShapes;

  const HaircutStyle({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.suitableFaceShapes,
  });

  bool isSuitableFor(FaceShape faceShape) {
    return suitableFaceShapes.contains(faceShape);
  }
}

// Lista de cortes de pelo predefinidos con sus descripciones y formas de rostro adecuadas
class HaircutDatabase {
  static List<HaircutStyle> getMaleHaircuts() {
    return [
      const HaircutStyle(
        name: 'Corte Undercut',
        description: 'Lados cortos y parte superior más larga. Ideal para añadir altura y estructura.',
        imageUrl: 'assets/images/undercut.jpg',
        suitableFaceShapes: [FaceShape.round, FaceShape.square, FaceShape.oval],
      ),
      const HaircutStyle(
        name: 'Pompadour',
        description: 'Volumen en la parte superior y lados más cortos. Alarga el rostro y añade estructura.',
        imageUrl: 'assets/images/pompadour.jpg',
        suitableFaceShapes: [FaceShape.round, FaceShape.heart, FaceShape.diamond],
      ),
      const HaircutStyle(
        name: 'Corte Fade',
        description: 'Degradado en los lados con longitud variable en la parte superior. Versátil para muchas formas de rostro.',
        imageUrl: 'assets/images/fade.jpg',
        suitableFaceShapes: [FaceShape.oval, FaceShape.square, FaceShape.diamond, FaceShape.triangle],
      ),
      const HaircutStyle(
        name: 'Corte Texturizado',
        description: 'Capas y textura para añadir movimiento. Suaviza rasgos angulares.',
        imageUrl: 'assets/images/textured.jpg',
        suitableFaceShapes: [FaceShape.square, FaceShape.diamond, FaceShape.oblong],
      ),
      const HaircutStyle(
        name: 'Corte Clásico Lateral',
        description: 'Elegante y atemporal. Raya lateral definida con longitud media en la parte superior.',
        imageUrl: 'assets/images/side_part.jpg',
        suitableFaceShapes: [FaceShape.oval, FaceShape.heart, FaceShape.diamond],
      ),
      const HaircutStyle(
        name: 'Buzz Cut',
        description: 'Corte muy corto y uniforme. Resalta las facciones faciales.',
        imageUrl: 'assets/images/buzz_cut.jpg',
        suitableFaceShapes: [FaceShape.oval, FaceShape.diamond],
      ),
      const HaircutStyle(
        name: 'Corte Medio con Flequillo',
        description: 'Longitud media con flequillo para suavizar la frente. Ideal para equilibrar facciones.',
        imageUrl: 'assets/images/medium_fringe.jpg',
        suitableFaceShapes: [FaceShape.oblong, FaceShape.square, FaceShape.heart],
      ),
      const HaircutStyle(
        name: 'Corte Largo Estructurado',
        description: 'Pelo largo con capas para añadir estructura y movimiento.',
        imageUrl: 'assets/images/long_structured.jpg',
        suitableFaceShapes: [FaceShape.oval, FaceShape.square, FaceShape.triangle],
      ),
    ];
  }

  static List<HaircutStyle> getFemaleHaircuts() {
    return [
      const HaircutStyle(
        name: 'Bob Clásico',
        description: 'Corte recto a la altura de la mandíbula. Añade anchura a los lados del rostro.',
        imageUrl: 'assets/images/bob.jpg',
        suitableFaceShapes: [FaceShape.oval, FaceShape.oblong, FaceShape.heart],
      ),
      const HaircutStyle(
        name: 'Lob (Long Bob)',
        description: 'Bob alargado hasta los hombros. Versátil y favorecedor para muchas formas de rostro.',
        imageUrl: 'assets/images/lob.jpg',
        suitableFaceShapes: [FaceShape.round, FaceShape.square, FaceShape.heart, FaceShape.oval],
      ),
      const HaircutStyle(
        name: 'Pixie',
        description: 'Corto y atrevido. Destaca los pómulos y los ojos.',
        imageUrl: 'assets/images/pixie.jpg',
        suitableFaceShapes: [FaceShape.oval, FaceShape.heart, FaceShape.diamond],
      ),
      const HaircutStyle(
        name: 'Capas Largas',
        description: 'Pelo largo con capas para añadir movimiento y volumen.',
        imageUrl: 'assets/images/long_layers.jpg',
        suitableFaceShapes: [FaceShape.square, FaceShape.round, FaceShape.oblong],
      ),
      const HaircutStyle(
        name: 'Media Melena con Flequillo',
        description: 'Longitud media con flequillo para enmarcar el rostro.',
        imageUrl: 'assets/images/medium_bangs.jpg',
        suitableFaceShapes: [FaceShape.oblong, FaceShape.square, FaceShape.diamond],
      ),
      const HaircutStyle(
        name: 'Shag Moderno',
        description: 'Corte desfilado con muchas capas y textura. Añade volumen y reduce anchura.',
        imageUrl: 'assets/images/shag.jpg',
        suitableFaceShapes: [FaceShape.round, FaceShape.square, FaceShape.heart],
      ),
      const HaircutStyle(
        name: 'Corte Asimétrico',
        description: 'Longitud desigual que añade interés visual y puede equilibrar facciones.',
        imageUrl: 'assets/images/asymmetric.jpg',
        suitableFaceShapes: [FaceShape.oval, FaceShape.round, FaceShape.square],
      ),
      const HaircutStyle(
        name: 'Ondas Suaves',
        description: 'Peinado con ondas que suaviza los rasgos y añade feminidad.',
        imageUrl: 'assets/images/soft_waves.jpg',
        suitableFaceShapes: [FaceShape.square, FaceShape.diamond, FaceShape.triangle],
      ),
    ];
  }

  static List<HaircutStyle> getHaircutsForFaceShape(FaceShape faceShape, bool isMale) {
    final List<HaircutStyle> allHaircuts = isMale ? getMaleHaircuts() : getFemaleHaircuts();
    return allHaircuts.where((haircut) => haircut.isSuitableFor(faceShape)).toList();
  }
} 