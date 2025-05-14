import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/face_analysis_bloc.dart';
import '../bloc/face_analysis_event.dart';
import '../bloc/face_analysis_state.dart';
import '../models/face_shape.dart';
import '../models/haircut_style.dart';
import '../widgets/loading_overlay.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Botón para reiniciar el proceso
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FaceAnalysisBloc>().add(ResetAnalysisEvent());
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: BlocBuilder<FaceAnalysisBloc, FaceAnalysisState>(
        builder: (context, state) {
          if (state is FaceAnalysisLoading) {
            return const LoadingOverlay(message: 'Cargando resultados...');
          } else if (state is FaceAnalysisComplete) {
            return _buildResultsView(context, state);
          } else {
            return const Center(
              child: Text('No hay resultados disponibles'),
            );
          }
        },
      ),
    );
  }

  Widget _buildResultsView(BuildContext context, FaceAnalysisComplete state) {
    final analysisResult = state.analysisResult;
    final faceShape = analysisResult.faceShape;
    final recommendedHaircuts = state.recommendedHaircuts ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen capturada con overlay del tipo de rostro
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen capturada
                  Image.file(
                    analysisResult.imageFile,
                    fit: BoxFit.cover,
                  ),
                  
                  // Overlay con el tipo de rostro
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      color: Colors.black.withOpacity(0.6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tipo de rostro: ${faceShape.displayName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Confianza: ${(analysisResult.detectedShapeConfidence * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Descripción del tipo de rostro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Características de tu tipo de rostro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      faceShape.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selector de género
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Mostrar cortes para:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Hombre'),
                  selected: state.isMale,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<FaceAnalysisBloc>().add(const SelectGenderEvent(true));
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Mujer'),
                  selected: !state.isMale,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<FaceAnalysisBloc>().add(const SelectGenderEvent(false));
                    }
                  },
                ),
              ],
            ),
          ),

          // Título de recomendaciones
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Cortes de pelo recomendados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Lista de cortes de pelo recomendados
          if (recommendedHaircuts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No hay recomendaciones disponibles para este tipo de rostro',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendedHaircuts.length,
              itemBuilder: (context, index) {
                final haircut = recommendedHaircuts[index];
                return _buildHaircutCard(context, haircut);
              },
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHaircutCard(BuildContext context, HaircutStyle haircut) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen del corte de pelo (placeholder)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          
          // Información del corte de pelo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  haircut.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  haircut.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 