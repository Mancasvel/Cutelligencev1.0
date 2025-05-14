import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import '../models/face_analysis_result.dart';
import '../models/face_shape.dart';
import '../models/haircut_style.dart';

abstract class FaceAnalysisState extends Equatable {
  const FaceAnalysisState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class FaceAnalysisInitial extends FaceAnalysisState {}

// Estado de carga
class FaceAnalysisLoading extends FaceAnalysisState {}

// Estado de error
class FaceAnalysisError extends FaceAnalysisState {
  final String message;

  const FaceAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}

// Estado cuando la cámara está lista
class CameraReady extends FaceAnalysisState {
  final CameraController cameraController;

  const CameraReady(this.cameraController);

  @override
  List<Object?> get props => [cameraController];
}

// Estado cuando se ha capturado una foto
class PhotoCaptured extends FaceAnalysisState {
  final File imageFile;

  const PhotoCaptured(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

// Estado cuando se ha completado el análisis facial
class FaceAnalysisComplete extends FaceAnalysisState {
  final FaceAnalysisResult analysisResult;
  final bool isMale;
  final List<HaircutStyle>? recommendedHaircuts;

  const FaceAnalysisComplete({
    required this.analysisResult,
    this.isMale = true,
    this.recommendedHaircuts,
  });

  @override
  List<Object?> get props => [analysisResult, isMale, recommendedHaircuts];

  // Método para crear una copia del estado con nuevos valores
  FaceAnalysisComplete copyWith({
    FaceAnalysisResult? analysisResult,
    bool? isMale,
    List<HaircutStyle>? recommendedHaircuts,
  }) {
    return FaceAnalysisComplete(
      analysisResult: analysisResult ?? this.analysisResult,
      isMale: isMale ?? this.isMale,
      recommendedHaircuts: recommendedHaircuts ?? this.recommendedHaircuts,
    );
  }
} 