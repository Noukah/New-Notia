import 'package:flutter_test/flutter_test.dart';
import 'package:notia/features/audio_recorder/data/services/audio_recorder_service.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_bloc.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_event.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_state.dart';
import 'package:notia/features/transcription/data/services/model_manager_service.dart';
import 'package:notia/features/transcription/domain/services/transcription_service.dart';
import 'package:record/record.dart';

class MockAudioRecorderService implements AudioRecorderService {
  bool permissionGranted = true;
  bool isRecording = false;

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<void> startRecording(String outputFilePath) async {
    isRecording = true;
  }

  @override
  Future<String?> stopRecording() async {
    isRecording = false;
    return 'fake/path/audio.wav';
  }

  @override
  Future<void> cancelRecording() async {
    isRecording = false;
  }

  @override
  Stream<RecordState> get stateStream => const Stream.empty();
}

class MockTranscriptionService implements TranscriptionService {
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize({required String modelDir}) async {
    _initialized = true;
  }

  @override
  Future<String> transcribe(String wavFilePath) async {
    return 'Esta es una transcripción de prueba exitosa';
  }

  @override
  void dispose() {
    _initialized = false;
  }
}

class MockModelManagerService implements ModelManagerService {
  @override
  Future<String> getModelDirectory() async => 'fake/model/dir';

  @override
  Future<bool> isDefaultModelReady() async => true;

  @override
  Future<void> prepareDefaultModel() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioRecorderBloc Tests', () {
    late MockAudioRecorderService mockRecorder;
    late MockTranscriptionService mockTranscription;
    late MockModelManagerService mockModelManager;
    late AudioRecorderBloc bloc;

    setUp(() {
      mockRecorder = MockAudioRecorderService();
      mockTranscription = MockTranscriptionService();
      mockModelManager = MockModelManagerService();
      bloc = AudioRecorderBloc(
        recorderService: mockRecorder,
        transcriptionService: mockTranscription,
        modelManagerService: mockModelManager,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AudioRecorderIdle', () {
      expect(bloc.state, isA<AudioRecorderIdle>());
    });

    test('starts recording and emits AudioRecordingInProgress', () async {
      bloc.add(const StartRecordingEvent('test/fake_audio.wav'));

      await expectLater(
        bloc.stream,
        emits(isA<AudioRecordingInProgress>()),
      );
      expect(mockRecorder.isRecording, isTrue);
    });

    test('stops recording and emits Transcribing then Success', () async {
      bloc.add(const StartRecordingEvent('test/fake_audio.wav'));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(StopRecordingAndTranscribeEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AudioTranscribingInProgress>(),
          predicate<AudioTranscriptionSuccess>((state) =>
              state.transcribedText == 'Esta es una transcripción de prueba exitosa'),
        ]),
      );
    });
  });
}
