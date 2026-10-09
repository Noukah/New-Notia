import 'dart:io';
import 'package:notia/features/transcription/data/models/stt_model_config.dart';
import 'package:notia/features/transcription/domain/services/transcription_service.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class SherpaTranscriptionServiceImpl implements TranscriptionService {
  sherpa.OfflineRecognizer? _recognizer;
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized && _recognizer != null;

  @override
  Future<void> initialize({required String modelDir}) async {
    final modelConfig = SttModelConfig.whisperTinySpanish(baseDir: modelDir);

    if (!modelConfig.filesExist) {
      throw FileNotFoundException(
        'Archivos del modelo no encontrados en: $modelDir. '
        'Asegúrate de que tiny-encoder.int8.onnx, tiny-decoder.int8.onnx y tokens.txt estén presentes.',
      );
    }

    final whisperConfig = sherpa.OfflineWhisperModelConfig(
      encoder: modelConfig.encoderPath,
      decoder: modelConfig.decoderPath,
      language: modelConfig.language,
      task: 'transcribe',
    );

    final offlineModelConfig = sherpa.OfflineModelConfig(
      whisper: whisperConfig,
      tokens: modelConfig.tokensPath,
      numThreads: 2,
      debug: false,
    );

    final config = sherpa.OfflineRecognizerConfig(
      model: offlineModelConfig,
    );

    // Liberar instancia anterior si existía
    _recognizer?.free();
    _recognizer = sherpa.OfflineRecognizer(config);
    _isInitialized = true;
  }

  @override
  Future<String> transcribe(String wavFilePath) async {
    if (!isInitialized || _recognizer == null) {
      throw StateError('El motor de transcripción no ha sido inicializado.');
    }

    final wavFile = File(wavFilePath);
    if (!await wavFile.exists()) {
      throw FileNotFoundException('El archivo de audio no existe: $wavFilePath');
    }

    final waveData = sherpa.readWave(wavFilePath);
    if (waveData.samples.isEmpty) {
      return '';
    }

    final stream = _recognizer!.createStream();
    try {
      stream.acceptWaveform(
        samples: waveData.samples,
        sampleRate: waveData.sampleRate,
      );
      _recognizer!.decode(stream);
      final result = _recognizer!.getResult(stream);
      return result.text.trim();
    } finally {
      stream.free();
    }
  }

  @override
  void dispose() {
    _recognizer?.free();
    _recognizer = null;
    _isInitialized = false;
  }
}

class FileNotFoundException implements Exception {
  final String message;
  FileNotFoundException(this.message);

  @override
  String toString() => 'FileNotFoundException: $message';
}
