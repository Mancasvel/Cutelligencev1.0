enum FaceShape {
  oval,
  round,
  square,
  heart,
  diamond,
  oblong,
  triangle,
  unknown;

  String get displayName {
    switch (this) {
      case FaceShape.oval:
        return 'Ovalado';
      case FaceShape.round:
        return 'Redondo';
      case FaceShape.square:
        return 'Cuadrado';
      case FaceShape.heart:
        return 'Corazón';
      case FaceShape.diamond:
        return 'Diamante';
      case FaceShape.oblong:
        return 'Alargado';
      case FaceShape.triangle:
        return 'Triángulo';
      case FaceShape.unknown:
        return 'Desconocido';
    }
  }

  String get description {
    switch (this) {
      case FaceShape.oval:
        return 'La forma ovalada es considerada la más equilibrada y versátil para diferentes estilos de cabello.';
      case FaceShape.round:
        return 'El rostro redondo tiene mejillas prominentes y una longitud y anchura similares.';
      case FaceShape.square:
        return 'El rostro cuadrado tiene una mandíbula fuerte y angular con una frente ancha.';
      case FaceShape.heart:
        return 'El rostro en forma de corazón tiene una frente ancha y se estrecha hacia una barbilla puntiaguda.';
      case FaceShape.diamond:
        return 'El rostro con forma de diamante tiene pómulos anchos con frente y mandíbula estrechas.';
      case FaceShape.oblong:
        return 'El rostro alargado es más largo que ancho, con una frente, mejillas y mandíbula de ancho similar.';
      case FaceShape.triangle:
        return 'El rostro triangular tiene una mandíbula ancha y se estrecha hacia la frente.';
      case FaceShape.unknown:
        return 'No se ha podido determinar la forma del rostro con precisión.';
    }
  }
} 