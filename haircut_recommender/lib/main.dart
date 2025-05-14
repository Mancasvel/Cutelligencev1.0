import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/face_analysis_bloc.dart';
import 'screens/camera_screen.dart';
import 'services/camera_service.dart';
import 'services/face_detection_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar la orientación de la aplicación
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const HairMatchApp());
}

class HairMatchApp extends StatelessWidget {
  const HairMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FaceAnalysisBloc>(
          create: (context) => FaceAnalysisBloc(
            cameraService: CameraService(),
            faceDetectionService: FaceDetectionService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'HairMatch',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(context),
        home: const CameraScreen(),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5C6BC0),
        brightness: Brightness.light,
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: baseTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
