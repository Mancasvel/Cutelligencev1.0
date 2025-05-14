import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/camera_service.dart';
import '../services/face_detection_service.dart';
import '../models/haircut_style.dart';
import '../models/face_shape.dart';
import 'face_analysis_event.dart';
import 'face_analysis_state.dart';

class FaceAnalysisBloc extends Bloc<FaceAnalysisEvent, FaceAnalysisState> {
  final CameraService _cameraService;
  final FaceDetectionService _faceDetectionService;

  FaceAnalysisBloc({
    required CameraService cameraService,
    required FaceDetectionService faceDetectionService,
  })  : _cameraService = cameraService,
        _faceDetectionService = faceDetectionService,
        super(FaceAnalysisInitial()) {
    on<InitializeCameraEvent>(_onInitializeCamera);
    on<ToggleCameraEvent>(_onToggleCamera);
    on<CapturePhotoEvent>(_onCapturePhoto);
    on<AnalyzeFaceEvent>(_onAnalyzeFace);
    on<SelectGenderEvent>(_onSelectGender);
    on<ResetAnalysisEvent>(_onResetAnalysis);
  }

  // Inicializar la cámara
  Future<void> _onInitializeCamera(
    InitializeCameraEvent event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    try {
      emit(FaceAnalysisLoading());
      await _cameraService.initialize();
      
      if (_cameraService.cameraController != null) {
        emit(CameraReady(_cameraService.cameraController!));
      } else {
        emit(const FaceAnalysisError('No se pudo inicializar la cámara'));
      }
    } catch (e) {
      emit(FaceAnalysisError('Error al inicializar la cámara: $e'));
    }
  }

  // Cambiar entre cámara frontal y trasera
  Future<void> _onToggleCamera(
    ToggleCameraEvent event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    try {
      emit(FaceAnalysisLoading());
      await _cameraService.toggleCamera();
      
      if (_cameraService.cameraController != null) {
        emit(CameraReady(_cameraService.cameraController!));
      } else {
        emit(const FaceAnalysisError('No se pudo cambiar la cámara'));
      }
    } catch (e) {
      emit(FaceAnalysisError('Error al cambiar la cámara: $e'));
    }
  }

  // Capturar una foto
  Future<void> _onCapturePhoto(
    CapturePhotoEvent event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    try {
      emit(FaceAnalysisLoading());
      final imageFile = await _cameraService.takePicture();
      
      if (imageFile != null) {
        emit(PhotoCaptured(imageFile));
      } else {
        emit(const FaceAnalysisError('No se pudo capturar la imagen'));
      }
    } catch (e) {
      emit(FaceAnalysisError('Error al capturar la imagen: $e'));
    }
  }

  // Analizar el rostro en la imagen
  Future<void> _onAnalyzeFace(
    AnalyzeFaceEvent event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    try {
      emit(FaceAnalysisLoading());
      
      final analysisResult = await _faceDetectionService.analyzeFace(event.imageFile);
      
      if (analysisResult.faceShape == FaceShape.unknown) {
        emit(const FaceAnalysisError('No se pudo detectar un rostro en la imagen'));
        return;
      }
      
      // Obtener recomendaciones para hombres por defecto
      final recommendedHaircuts = HaircutDatabase.getHaircutsForFaceShape(
        analysisResult.faceShape,
        true, // Por defecto, mostrar cortes masculinos
      );
      
      emit(FaceAnalysisComplete(
        analysisResult: analysisResult,
        isMale: true,
        recommendedHaircuts: recommendedHaircuts,
      ));
    } catch (e) {
      emit(FaceAnalysisError('Error al analizar el rostro: $e'));
    }
  }

  // Seleccionar género para las recomendaciones
  Future<void> _onSelectGender(
    SelectGenderEvent event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is FaceAnalysisComplete) {
      final recommendedHaircuts = HaircutDatabase.getHaircutsForFaceShape(
        currentState.analysisResult.faceShape,
        event.isMale,
      );
      
      emit(currentState.copyWith(
        isMale: event.isMale,
        recommendedHaircuts: recommendedHaircuts,
      ));
    }
  }

  // Reiniciar el proceso de análisis
  Future<void> _onResetAnalysis(
    ResetAnalysisEvent event,
    Emitter<FaceAnalysisState> emit,
  ) async {
    try {
      emit(FaceAnalysisLoading());
      
      // Verificar si la cámara ya está inicializada
      if (!_cameraService.isInitialized) {
        await _cameraService.initialize();
      }
      
      if (_cameraService.cameraController != null) {
        emit(CameraReady(_cameraService.cameraController!));
      } else {
        emit(const FaceAnalysisError('No se pudo reiniciar el análisis'));
      }
    } catch (e) {
      emit(FaceAnalysisError('Error al reiniciar el análisis: $e'));
    }
  }

  @override
  Future<void> close() {
    _cameraService.dispose();
    _faceDetectionService.dispose();
    return super.close();
  }
} 