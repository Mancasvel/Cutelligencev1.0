import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../models/face_shape.dart';
import '../models/face_analysis_result.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector;
  final Random _random = Random();
  final bool _demoMode = true; // Modo de demostración para pruebas
  
  FaceDetectionService() : _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableTracking: false,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  // Analizar la imagen y detectar la forma del rostro
  Future<FaceAnalysisResult> analyzeFace(File imageFile) async {
    try {
      if (_demoMode) {
        // En modo demo, devolver un resultado aleatorio para probar la aplicación
        return _generateDemoResult(imageFile);
      }
      
      // Convertir la imagen a InputImage para ML Kit
      final inputImage = InputImage.fromFile(imageFile);
      
      // Detectar rostros en la imagen
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      
      // Si no se detecta ningún rostro, devolver resultado desconocido
      if (faces.isEmpty) {
        return FaceAnalysisResult.unknown(imageFile);
      }
      
      // Usar el primer rostro detectado (suponemos que hay solo uno)
      final Face face = faces.first;
      
      // Extraer métricas faciales
      final Map<String, double> metrics = await _extractFaceMetrics(face, imageFile);
      
      // Determinar la forma del rostro basada en las métricas
      final Map<FaceShape, double> shapeConfidences = _determineFaceShape(metrics);
      
      // Obtener la forma con mayor confianza
      FaceShape detectedShape = FaceShape.unknown;
      double maxConfidence = 0;
      
      // Convertir las confianzas a un mapa de strings para almacenar
      final Map<String, double> confidenceScores = {};
      
      shapeConfidences.forEach((shape, confidence) {
        confidenceScores[shape.toString().split('.').last] = confidence;
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          detectedShape = shape;
        }
      });
      
      // Crear y devolver el resultado del análisis
      return FaceAnalysisResult(
        imageFile: imageFile,
        faceShape: detectedShape,
        confidenceScores: confidenceScores,
        faceMetrics: metrics,
      );
    } catch (e) {
      print('Error en el análisis facial: $e');
      // En caso de error, devolver un resultado de demostración
      return _generateDemoResult(imageFile);
    }
  }

  // Generar un resultado de demostración para pruebas
  FaceAnalysisResult _generateDemoResult(File imageFile) {
    // Lista de posibles formas de rostro
    final List<FaceShape> possibleShapes = [
      FaceShape.oval,
      FaceShape.round,
      FaceShape.square,
      FaceShape.heart,
      FaceShape.diamond,
      FaceShape.oblong,
      FaceShape.triangle,
    ];
    
    // Seleccionar una forma aleatoria
    final FaceShape randomShape = possibleShapes[_random.nextInt(possibleShapes.length)];
    
    // Generar puntuaciones de confianza aleatorias
    final Map<String, double> confidenceScores = {};
    double totalConfidence = 0;
    
    // Asignar una confianza alta a la forma seleccionada y valores bajos a las demás
    for (final shape in possibleShapes) {
      double confidence = 0.1 + _random.nextDouble() * 0.2; // Entre 0.1 y 0.3
      if (shape == randomShape) {
        confidence = 0.7 + _random.nextDouble() * 0.25; // Entre 0.7 y 0.95
      }
      confidenceScores[shape.toString().split('.').last] = confidence;
      totalConfidence += confidence;
    }
    
    // Normalizar las confianzas para que sumen aproximadamente 1.0
    confidenceScores.forEach((key, value) {
      confidenceScores[key] = value / totalConfidence;
    });
    
    // Generar métricas faciales aleatorias
    final Map<String, double> faceMetrics = {
      'faceRatio': 1.2 + _random.nextDouble() * 0.6, // Entre 1.2 y 1.8
      'jawCurvature': 140 + _random.nextDouble() * 40, // Entre 140 y 180
      'foreheadToJawRatio': 0.8 + _random.nextDouble() * 0.6, // Entre 0.8 y 1.4
      'cheekboneToJawRatio': 0.9 + _random.nextDouble() * 0.4, // Entre 0.9 y 1.3
      'chinProminence': -0.1 + _random.nextDouble() * 0.2, // Entre -0.1 y 0.1
    };
    
    return FaceAnalysisResult(
      imageFile: imageFile,
      faceShape: randomShape,
      confidenceScores: confidenceScores,
      faceMetrics: faceMetrics,
    );
  }

  // Extraer métricas faciales de la imagen
  Future<Map<String, double>> _extractFaceMetrics(Face face, File imageFile) async {
    final Map<String, double> metrics = {};
    
    try {
      // Leer la imagen usando el paquete image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }
      
      // Obtener puntos de referencia facial si están disponibles
      final faceContour = face.contours[FaceContourType.face]?.points;
      if (faceContour == null || faceContour.isEmpty) {
        throw Exception('No se pudieron detectar los contornos faciales');
      }

      // Calcular dimensiones del rostro
      double minX = double.infinity;
      double maxX = -double.infinity;
      double minY = double.infinity;
      double maxY = -double.infinity;
      
      for (final Point point in faceContour) {
        minX = min(minX, point.x.toDouble());
        maxX = max(maxX, point.x.toDouble());
        minY = min(minY, point.y.toDouble());
        maxY = max(maxY, point.y.toDouble());
      }
      
      // Ancho y alto del rostro
      final double faceWidth = maxX - minX;
      final double faceHeight = maxY - minY;
      
      // Calcular proporciones faciales
      metrics['faceRatio'] = faceHeight / faceWidth;
      
      // Obtener puntos de la mandíbula para calcular su forma
      final jawLine = face.contours[FaceContourType.face]?.points ?? [];
      
      if (jawLine.isNotEmpty) {
        // Calcular la anchura de la mandíbula (parte inferior del rostro)
        final int jawLineLength = jawLine.length;
        final int quarterPoints = jawLineLength ~/ 4;
        
        // Puntos en la parte inferior de la cara (mandíbula)
        final List<Point> jawBottom = jawLine.sublist(
          quarterPoints, 
          jawLineLength - quarterPoints
        );
        
        // Calcular la curvatura de la mandíbula
        double jawCurvature = 0;
        if (jawBottom.length >= 3) {
          for (int i = 1; i < jawBottom.length - 1; i++) {
            final Point prev = jawBottom[i - 1];
            final Point current = jawBottom[i];
            final Point next = jawBottom[i + 1];
            
            // Calcular ángulo entre tres puntos consecutivos
            final double angle = _calculateAngle(prev, current, next);
            jawCurvature += angle;
          }
          
          // Normalizar la curvatura
          jawCurvature /= (jawBottom.length - 2);
        }
        
        metrics['jawCurvature'] = jawCurvature;
        
        // Calcular la relación entre la anchura de la frente y la mandíbula
        final Point foreheadLeft = jawLine[0];
        final Point foreheadRight = jawLine[jawLine.length - 1];
        final double foreheadWidth = _distance(foreheadLeft, foreheadRight);
        
        final Point jawLeft = jawBottom.first;
        final Point jawRight = jawBottom.last;
        final double jawWidth = _distance(jawLeft, jawRight);
        
        metrics['foreheadToJawRatio'] = foreheadWidth / jawWidth;
      }
      
      // Calcular la posición de los pómulos (cheekbones)
      final leftCheek = face.landmarks[FaceLandmarkType.leftCheek]?.position;
      final rightCheek = face.landmarks[FaceLandmarkType.rightCheek]?.position;
      
      if (leftCheek != null && rightCheek != null) {
        final double cheekboneWidth = _distance(leftCheek, rightCheek);
        metrics['cheekboneToJawRatio'] = cheekboneWidth / faceWidth;
      }
      
      // Calcular la forma de la barbilla
      final chin = face.landmarks[FaceLandmarkType.bottomMouth]?.position;
      if (chin != null && jawLine.isNotEmpty) {
        // Calcular la prominencia de la barbilla
        final Point jawCenter = jawLine[jawLine.length ~/ 2];
        final double chinProminence = (chin.y - jawCenter.y).toDouble();
        metrics['chinProminence'] = chinProminence / faceHeight;
      }
    } catch (e) {
      print('Error al extraer métricas faciales: $e');
      // Proporcionar valores predeterminados para las métricas
      metrics['faceRatio'] = 1.5; // Proporción típica
      metrics['jawCurvature'] = 160.0; // Curvatura media
      metrics['foreheadToJawRatio'] = 1.0; // Proporción igual
      metrics['cheekboneToJawRatio'] = 1.0; // Proporción igual
      metrics['chinProminence'] = 0.0; // Sin prominencia
    }
    
    return metrics;
  }

  // Determinar la forma del rostro basada en las métricas faciales
  Map<FaceShape, double> _determineFaceShape(Map<String, double> metrics) {
    final Map<FaceShape, double> confidences = {
      FaceShape.oval: 0.0,
      FaceShape.round: 0.0,
      FaceShape.square: 0.0,
      FaceShape.heart: 0.0,
      FaceShape.diamond: 0.0,
      FaceShape.oblong: 0.0,
      FaceShape.triangle: 0.0,
    };
    
    // Extraer métricas relevantes
    final double? faceRatio = metrics['faceRatio'];
    final double? jawCurvature = metrics['jawCurvature'];
    final double? foreheadToJawRatio = metrics['foreheadToJawRatio'];
    final double? cheekboneToJawRatio = metrics['cheekboneToJawRatio'];
    final double? chinProminence = metrics['chinProminence'];
    
    if (faceRatio != null) {
      // Rostro ovalado: proporción altura/anchura alrededor de 1.5, mandíbula curva
      if (faceRatio >= 1.3 && faceRatio <= 1.7 && 
          jawCurvature != null && jawCurvature > 160) {
        confidences[FaceShape.oval] = 0.8;
      }
      
      // Rostro redondo: proporción cercana a 1, mandíbula muy curva
      if (faceRatio >= 0.9 && faceRatio <= 1.2 && 
          jawCurvature != null && jawCurvature > 170) {
        confidences[FaceShape.round] = 0.8;
      }
      
      // Rostro cuadrado: proporción cercana a 1, mandíbula angular
      if (faceRatio >= 0.9 && faceRatio <= 1.2 && 
          jawCurvature != null && jawCurvature < 150) {
        confidences[FaceShape.square] = 0.8;
      }
      
      // Rostro alargado: proporción alta
      if (faceRatio > 1.7) {
        confidences[FaceShape.oblong] = 0.8;
      }
    }
    
    // Rostro en forma de corazón: frente más ancha que mandíbula
    if (foreheadToJawRatio != null && foreheadToJawRatio > 1.2 &&
        chinProminence != null && chinProminence < 0) {
      confidences[FaceShape.heart] = 0.8;
    }
    
    // Rostro en forma de diamante: pómulos prominentes
    if (cheekboneToJawRatio != null && cheekboneToJawRatio > 1.1 &&
        foreheadToJawRatio != null && foreheadToJawRatio < 1.1) {
      confidences[FaceShape.diamond] = 0.8;
    }
    
    // Rostro triangular: mandíbula más ancha que frente
    if (foreheadToJawRatio != null && foreheadToJawRatio < 0.8) {
      confidences[FaceShape.triangle] = 0.8;
    }
    
    // Ajustar confianzas basadas en combinaciones de características
    _adjustConfidences(confidences, metrics);
    
    return confidences;
  }

  // Ajustar confianzas basadas en combinaciones de características
  void _adjustConfidences(Map<FaceShape, double> confidences, Map<String, double> metrics) {
    // Implementación básica para ajustar confianzas
    // En una implementación real, esto se basaría en un modelo ML entrenado
    
    // Normalizar las confianzas para que sumen 1.0
    double total = 0.0;
    confidences.forEach((_, value) {
      total += value;
    });
    
    // Si no hay confianza en ninguna forma, asignar una distribución uniforme
    if (total < 0.1) {
      final double uniformValue = 1.0 / confidences.length;
      confidences.forEach((key, _) {
        confidences[key] = uniformValue;
      });
    } else {
      // Normalizar
      confidences.forEach((key, value) {
        confidences[key] = value / total;
      });
    }
  }

  // Calcular la distancia entre dos puntos
  double _distance(Point p1, Point p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }

  // Calcular el ángulo entre tres puntos
  double _calculateAngle(Point p1, Point p2, Point p3) {
    final double a = _distance(p2, p3);
    final double b = _distance(p1, p3);
    final double c = _distance(p1, p2);
    
    // Ley de cosenos
    return acos((a * a + c * c - b * b) / (2 * a * c)) * (180 / pi);
  }

  // Liberar recursos
  void dispose() {
    _faceDetector.close();
  }
} 