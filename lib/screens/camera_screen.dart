import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/face_analysis_bloc.dart';
import '../bloc/face_analysis_event.dart';
import '../bloc/face_analysis_state.dart';
import '../widgets/loading_overlay.dart';
import 'photo_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Inicializar la cámara cuando se carga la pantalla
    context.read<FaceAnalysisBloc>().add(InitializeCameraEvent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gestionar el ciclo de vida de la aplicación para la cámara
    final FaceAnalysisBloc bloc = context.read<FaceAnalysisBloc>();
    
    if (state == AppLifecycleState.inactive) {
      // La app está en segundo plano, reiniciar la cámara cuando vuelva
    } else if (state == AppLifecycleState.resumed) {
      // La app vuelve a primer plano, reiniciar la cámara
      bloc.add(InitializeCameraEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HairMatch'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<FaceAnalysisBloc, FaceAnalysisState>(
        listener: (context, state) {
          if (state is PhotoCaptured) {
            // Navegar a la pantalla de vista previa cuando se captura una foto
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoPreviewScreen(imageFile: state.imageFile),
              ),
            );
          } else if (state is FaceAnalysisError) {
            // Mostrar mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is FaceAnalysisLoading) {
            return const LoadingOverlay(message: 'Preparando cámara...');
          } else if (state is CameraReady) {
            return _buildCameraView(context, state.cameraController);
          } else {
            return const Center(child: Text('Inicializando cámara...'));
          }
        },
      ),
    );
  }

  Widget _buildCameraView(BuildContext context, CameraController controller) {
    final size = MediaQuery.of(context).size;
    
    // Calcular la relación de aspecto de la cámara
    final scale = 1 / (controller.value.aspectRatio * size.aspectRatio);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Vista previa de la cámara
        Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: CameraPreview(controller),
        ),
        
        // Overlay para guiar al usuario
        _buildFaceOverlay(size),
        
        // Botones de control
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: _buildControlButtons(context),
        ),
        
        // Instrucciones para el usuario
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.black45,
            child: const Text(
              'Coloca tu rostro dentro del óvalo y asegúrate de tener buena iluminación',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceOverlay(Size size) {
    return CustomPaint(
      size: size,
      painter: FaceOverlayPainter(),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón para cambiar de cámara
        FloatingActionButton(
          heroTag: 'toggleCamera',
          onPressed: () {
            context.read<FaceAnalysisBloc>().add(ToggleCameraEvent());
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.flip_camera_ios, color: Colors.black),
        ),
        
        // Botón para tomar la foto
        FloatingActionButton(
          heroTag: 'takePhoto',
          onPressed: () {
            context.read<FaceAnalysisBloc>().add(CapturePhotoEvent());
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.camera, color: Colors.black, size: 30),
        ),
        
        // Botón de ayuda
        FloatingActionButton(
          heroTag: 'help',
          onPressed: () {
            _showHelpDialog(context);
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.help, color: Colors.black),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consejos para una mejor detección'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Asegúrate de tener buena iluminación'),
              SizedBox(height: 8),
              Text('• Coloca tu rostro de frente a la cámara'),
              SizedBox(height: 8),
              Text('• Quita cualquier objeto que cubra tu rostro (gafas, pelo, etc.)'),
              SizedBox(height: 8),
              Text('• Mantén una expresión neutral'),
              SizedBox(height: 8),
              Text('• Evita sombras fuertes en el rostro'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para dibujar un óvalo guía
class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar un óvalo para guiar al usuario
    final double ovalWidth = size.width * 0.65;
    final double ovalHeight = size.height * 0.5;
    
    final Rect ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: ovalWidth,
      height: ovalHeight,
    );
    
    canvas.drawOval(ovalRect, paint);
    
    // Dibujar líneas guía
    final Paint dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Línea horizontal central
    canvas.drawLine(
      Offset(size.width / 2 - ovalWidth / 2, size.height * 0.45),
      Offset(size.width / 2 + ovalWidth / 2, size.height * 0.45),
      dashPaint,
    );
    
    // Línea vertical central
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.45 - ovalHeight / 2),
      Offset(size.width / 2, size.height * 0.45 + ovalHeight / 2),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 