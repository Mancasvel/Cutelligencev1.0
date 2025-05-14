import 'dart:io';
import 'package:equatable/equatable.dart';
import '../models/face_shape.dart';

abstract class FaceAnalysisEvent extends Equatable {
  const FaceAnalysisEvent();

  @override
  List<Object?> get props => [];
}

// Evento para iniciar la cámara
class InitializeCameraEvent extends FaceAnalysisEvent {}

// Evento para cambiar entre cámara frontal y trasera
class ToggleCameraEvent extends FaceAnalysisEvent {}

// Evento para tomar una foto
class CapturePhotoEvent extends FaceAnalysisEvent {}

// Evento para analizar una imagen
class AnalyzeFaceEvent extends FaceAnalysisEvent {
  final File imageFile;

  const AnalyzeFaceEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

// Evento para seleccionar el género para las recomendaciones
class SelectGenderEvent extends FaceAnalysisEvent {
  final bool isMale;

  const SelectGenderEvent(this.isMale);

  @override
  List<Object?> get props => [isMale];
}

// Evento para reiniciar el proceso
class ResetAnalysisEvent extends FaceAnalysisEvent {} 