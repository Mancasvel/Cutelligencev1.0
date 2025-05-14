import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/face_analysis_bloc.dart';
import '../bloc/face_analysis_event.dart';
import '../bloc/face_analysis_state.dart';
import '../widgets/loading_overlay.dart';
import 'results_screen.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final File imageFile;

  const PhotoPreviewScreen({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<FaceAnalysisBloc, FaceAnalysisState>(
        listener: (context, state) {
          if (state is FaceAnalysisComplete) {
            // Navegar a la pantalla de resultados cuando se completa el análisis
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ResultsScreen(),
              ),
            );
          } else if (state is FaceAnalysisError) {
            // Mostrar mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Reintentar',
                  onPressed: () {
                    // Usar Navigator.of(context) con un contexto válido
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // Si no podemos hacer pop, reiniciamos el análisis
                      context.read<FaceAnalysisBloc>().add(ResetAnalysisEvent());
                    }
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FaceAnalysisLoading) {
            return Stack(
              children: [
                _buildImagePreview(context),
                const LoadingOverlay(message: 'Analizando rostro...'),
              ],
            );
          } else {
            return _buildImagePreview(context);
          }
        },
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Te gusta esta foto?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tomar otra'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Iniciar el análisis facial con la imagen capturada
                        context.read<FaceAnalysisBloc>().add(AnalyzeFaceEvent(imageFile));
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Analizar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 