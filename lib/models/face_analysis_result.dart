import 'dart:io';
import 'face_shape.dart';

class FaceAnalysisResult {
  final File imageFile;
  final FaceShape faceShape;
  final Map<String, double> confidenceScores;
  final Map<String, double> faceMetrics;
  final DateTime analysisDate;

  FaceAnalysisResult({
    required this.imageFile,
    required this.faceShape,
    required this.confidenceScores,
    required this.faceMetrics,
    DateTime? analysisDate,
  }) : analysisDate = analysisDate ?? DateTime.now();

  // Método para obtener la puntuación de confianza para la forma detectada
  double get detectedShapeConfidence => 
      confidenceScores[faceShape.toString().split('.').last] ?? 0.0;

  // Método para obtener las métricas principales del rostro
  Map<String, String> get formattedMetrics {
    final Map<String, String> formatted = {};
    faceMetrics.forEach((key, value) {
      formatted[key] = value.toStringAsFixed(2);
    });
    return formatted;
  }

  // Método para verificar si la detección es confiable
  bool get isReliableDetection => detectedShapeConfidence > 0.65;

  // Factory para crear un resultado de análisis con forma desconocida
  factory FaceAnalysisResult.unknown(File imageFile) {
    return FaceAnalysisResult(
      imageFile: imageFile,
      faceShape: FaceShape.unknown,
      confidenceScores: {},
      faceMetrics: {},
    );
  }
} 