import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

abstract class AudioRecorderService {
  Future<bool> hasPermission();
  Future<void> startRecording(String outputFilePath);
  Future<String?> stopRecording();
  Future<void> cancelRecording();
  Stream<RecordState> get stateStream;
}

class AudioRecorderServiceImpl implements AudioRecorderService {
  final AudioRecorder _recorder;

  AudioRecorderServiceImpl([AudioRecorder? recorder])
      : _recorder = recorder ?? AudioRecorder();

  @override
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<void> startRecording(String outputFilePath) async {
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      throw Exception('Permiso de grabación de audio denegado');
    }

    // Configuración óptima para Sherpa ONNX: WAV 16kHz, mono, PCM 16-bit
    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 128000,
    );

    await _recorder.start(config, path: outputFilePath);
  }

  @override
  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    return path;
  }

  @override
  Future<void> cancelRecording() async {
    await _recorder.cancel();
  }

  @override
  Stream<RecordState> get stateStream => _recorder.onStateChanged();

  /// Helper para generar una ruta temporal de grabación
  static Future<String> generateNewRecordingPath() async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'rec_${DateTime.now().millisecondsSinceEpoch}.wav';
    final dir = Directory('${tempDir.path}/recordings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '${dir.path}/$fileName';
  }

  void dispose() {
    _recorder.dispose();
  }
}
