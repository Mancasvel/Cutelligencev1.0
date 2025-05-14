import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;

  // Inicializar la cámara
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Solicitar permisos de cámara
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission.isDenied) {
      throw Exception('Se requieren permisos de cámara para usar esta aplicación');
    }

    // Obtener las cámaras disponibles
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No se encontraron cámaras disponibles');
    }

    // Usar la cámara frontal por defecto si está disponible
    final frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    // Inicializar el controlador de la cámara
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Inicializar el controlador
    await _cameraController!.initialize();
    _isInitialized = true;
  }

  // Tomar una foto y guardarla
  Future<File?> takePicture() async {
    if (!_isInitialized || _cameraController == null) {
      throw Exception('La cámara no está inicializada');
    }

    try {
      // Tomar la foto
      final XFile imageFile = await _cameraController!.takePicture();
      
      // Guardar la imagen en un directorio temporal
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = path.join(
        tempDir.path,
        'haircut_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      // Copiar la imagen al directorio temporal
      final File savedImage = File(filePath);
      await savedImage.writeAsBytes(await File(imageFile.path).readAsBytes());
      
      return savedImage;
    } catch (e) {
      print('Error al tomar la foto: $e');
      return null;
    }
  }

  // Cambiar entre cámara frontal y trasera
  Future<void> toggleCamera() async {
    if (!_isInitialized || _cameras == null || _cameras!.length < 2) {
      return;
    }

    final CameraLensDirection currentDirection = _cameraController!.description.lensDirection;
    CameraDescription newCamera;

    if (currentDirection == CameraLensDirection.front) {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
    } else {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
    }

    // Liberar el controlador actual
    await _cameraController!.dispose();
    
    // Crear un nuevo controlador con la cámara seleccionada
    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Inicializar el nuevo controlador
    await _cameraController!.initialize();
  }

  // Liberar recursos cuando ya no se necesiten
  Future<void> dispose() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _isInitialized = false;
    }
  }
} 