import 'package:flutter_test/flutter_test.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

void main() {
  test('Check Whisper and SenseVoice configs in OfflineModelConfig', () {
    const whisperConfig = sherpa.OfflineWhisperModelConfig(
      encoder: 'encoder.onnx',
      decoder: 'decoder.onnx',
      language: 'es',
      task: 'transcribe',
    );

    const modelConfig = sherpa.OfflineModelConfig(
      whisper: whisperConfig,
      tokens: 'tokens.txt',
      numThreads: 2,
      debug: false,
    );

    const config = sherpa.OfflineRecognizerConfig(
      model: modelConfig,
    );

    expect(config.model.whisper.language, equals('es'));
    expect(config.model.tokens, equals('tokens.txt'));
  });
}
