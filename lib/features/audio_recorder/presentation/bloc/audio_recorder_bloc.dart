import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notia/features/audio_recorder/data/services/audio_recorder_service.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_event.dart';
import 'package:notia/features/audio_recorder/presentation/bloc/audio_recorder_state.dart';
import 'package:notia/features/transcription/data/services/model_manager_service.dart';
import 'package:notia/features/transcription/domain/services/transcription_service.dart';

class AudioRecorderBloc extends Bloc<AudioRecorderEvent, AudioRecorderState> {
  final AudioRecorderService recorderService;
  final TranscriptionService transcriptionService;
  final ModelManagerService modelManagerService;

  String? _currentRecordingPath;

  AudioRecorderBloc({
    required this.recorderService,
    required this.transcriptionService,
    required this.modelManagerService,
  }) : super(const AudioRecorderIdle()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingAndTranscribeEvent>(_onStopRecordingAndTranscribe);
    on<CancelRecordingEvent>(_onCancelRecording);
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<AudioRecorderState> emit,
  ) async {
    try {
      final hasPerm = await recorderService.hasPermission();
      if (!hasPerm) {
        emit(const AudioRecorderFailure(
          errorMessage: 'No se cuenta con permisos para acceder al micrófono.',
        ));
        return;
      }

      final path = event.outputPath ?? await AudioRecorderServiceImpl.generateNewRecordingPath();
      _currentRecordingPath = path;

      await recorderService.startRecording(path);
      emit(AudioRecordingInProgress(
        recordingPath: path,
        startTime: DateTime.now(),
      ));
    } catch (e) {
      emit(AudioRecorderFailure(
        errorMessage: 'Error al iniciar la grabación: $e',
      ));
    }
  }

  Future<void> _onStopRecordingAndTranscribe(
    StopRecordingAndTranscribeEvent event,
    Emitter<AudioRecorderState> emit,
  ) async {
    try {
      final path = await recorderService.stopRecording() ?? _currentRecordingPath;
      if (path == null) {
        emit(const AudioRecorderFailure(
          errorMessage: 'No se encontró la ruta del archivo de audio grabado.',
        ));
        return;
      }

      emit(AudioTranscribingInProgress(recordingPath: path));

      // Verificar si el reconocedor ya está inicializado
      if (!transcriptionService.isInitialized) {
        final modelDir = await modelManagerService.getModelDirectory();
        final isReady = await modelManagerService.isDefaultModelReady();

        if (!isReady) {
          emit(const AudioRecorderFailure(
            errorMessage: 'El modelo de transcripción en español aún no está instalado en el dispositivo.',
          ));
          return;
        }

        await transcriptionService.initialize(modelDir: modelDir);
      }

      final text = await transcriptionService.transcribe(path);
      emit(AudioTranscriptionSuccess(
        transcribedText: text,
        recordingPath: path,
      ));
    } catch (e) {
      emit(AudioRecorderFailure(
        errorMessage: 'Error durante la transcripción: $e',
      ));
    }
  }

  Future<void> _onCancelRecording(
    CancelRecordingEvent event,
    Emitter<AudioRecorderState> emit,
  ) async {
    try {
      await recorderService.cancelRecording();
      _currentRecordingPath = null;
      emit(const AudioRecorderIdle());
    } catch (e) {
      emit(AudioRecorderFailure(
        errorMessage: 'Error al cancelar la grabación: $e',
      ));
    }
  }
}
