import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:notia/core/storage/secure_storage_service.dart';
import 'package:notia/features/audio_recorder/data/services/audio_recorder_service.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_bloc.dart';
import 'package:notia/core/widgets/app_icon.dart';
import 'package:notia/features/home/presentation/widgets/floating_dock.dart';
import 'package:notia/features/home/presentation/screens/home_screen.dart';
import 'package:notia/features/transcription/data/services/model_manager_service.dart';
import 'package:notia/features/transcription/domain/services/transcription_service.dart';
import 'package:record/record.dart';

class MockAudioRecorderService implements AudioRecorderService {
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<void> startRecording(String outputFilePath) async {}
  @override
  Future<String?> stopRecording() async => 'test.wav';
  @override
  Future<void> cancelRecording() async {}
  @override
  Stream<RecordState> get stateStream => const Stream.empty();
}

class MockTranscriptionService implements TranscriptionService {
  @override
  bool get isInitialized => true;
  @override
  Future<void> initialize({required String modelDir}) async {}
  @override
  Future<String> transcribe(String wavFilePath) async => 'Test';
  @override
  void dispose() {}
}

class MockModelManagerService implements ModelManagerService {
  @override
  Future<String> getModelDirectory() async => 'test_dir';
  @override
  Future<bool> isDefaultModelReady() async => true;
  @override
  Future<void> prepareDefaultModel() async {}
}

void main() {
  testWidgets('HomeScreen renders dual circles and bottom dock smoke test', (WidgetTester tester) async {
    final mockRecorder = MockAudioRecorderService();
    final mockTranscription = MockTranscriptionService();
    final mockModelManager = MockModelManagerService();
    final mockStorage = SecureStorageService();

    final bloc = AudioRecorderBloc(
      recorderService: mockRecorder,
      transcriptionService: mockTranscription,
      modelManagerService: mockModelManager,
    );

    await tester.pumpWidget(
      BlocProvider<AudioRecorderBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: HomeScreen(
            secureStorageService: mockStorage,
          ),
        ),
      ),
    );

    // Verify main components are present
    expect(find.text('Grabar voz'), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byType(FloatingDock), findsOneWidget);
    expect(find.byType(AppIcon), findsWidgets);

    bloc.close();
  });
}
