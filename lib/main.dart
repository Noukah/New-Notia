import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notia/core/storage/secure_storage_service.dart';
import 'package:notia/core/theme/app_theme.dart';
import 'package:notia/features/audio_recorder/data/services/audio_recorder_service.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_bloc.dart';
import 'package:notia/features/home/presentation/screens/home_screen.dart';
import 'package:notia/features/transcription/data/services/model_manager_service.dart';
import 'package:notia/features/transcription/data/services/sherpa_transcription_service.dart';

import 'package:notia/features/transcription/domain/services/transcription_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final secureStorageService = SecureStorageService();
  final audioRecorderService = AudioRecorderServiceImpl();
  final transcriptionService = SherpaTranscriptionServiceImpl();
  final modelManagerService = ModelManagerServiceImpl();

  runApp(
    NotiaApp(
      secureStorageService: secureStorageService,
      audioRecorderService: audioRecorderService,
      transcriptionService: transcriptionService,
      modelManagerService: modelManagerService,
    ),
  );
}

class NotiaApp extends StatelessWidget {
  final SecureStorageService secureStorageService;
  final AudioRecorderService audioRecorderService;
  final TranscriptionService transcriptionService;
  final ModelManagerService modelManagerService;

  const NotiaApp({
    super.key,
    required this.secureStorageService,
    required this.audioRecorderService,
    required this.transcriptionService,
    required this.modelManagerService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudioRecorderBloc>(
          create: (context) => AudioRecorderBloc(
            recorderService: audioRecorderService,
            transcriptionService: transcriptionService,
            modelManagerService: modelManagerService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Notia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Modo oscuro por defecto como en Figma
        home: HomeScreen(
          secureStorageService: secureStorageService,
        ),
      ),
    );
  }
}
