abstract class TranscriptionService {
  /// Inicializa el motor de reconocimiento con los modelos locales
  Future<void> initialize({required String modelDir});

  /// Transcribe un archivo de audio WAV (16kHz mono) a texto
  Future<String> transcribe(String wavFilePath);

  /// Indica si el motor está listo para transcribir
  bool get isInitialized;

  /// Libera recursos en memoria
  void dispose();
}
