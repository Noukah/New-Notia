import 'dart:io';

class SttModelConfig {
  final String modelName;
  final String language;
  final String encoderPath;
  final String decoderPath;
  final String tokensPath;

  const SttModelConfig({
    required this.modelName,
    required this.language,
    required this.encoderPath,
    required this.decoderPath,
    required this.tokensPath,
  });

  /// Verifica si los archivos requeridos existen en el disco
  bool get filesExist {
    return File(encoderPath).existsSync() &&
        File(decoderPath).existsSync() &&
        File(tokensPath).existsSync();
  }

  /// Configuración por defecto para Whisper Tiny en español
  factory SttModelConfig.whisperTinySpanish({required String baseDir}) {
    final separator = Platform.pathSeparator;
    return SttModelConfig(
      modelName: 'whisper-tiny-es',
      language: 'es',
      encoderPath: '$baseDir${separator}tiny-encoder.int8.onnx',
      decoderPath: '$baseDir${separator}tiny-decoder.int8.onnx',
      tokensPath: '$baseDir${separator}tokens.txt',
    );
  }
}
