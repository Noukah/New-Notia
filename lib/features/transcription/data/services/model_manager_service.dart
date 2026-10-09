import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notia/features/transcription/data/models/stt_model_config.dart';

abstract class ModelManagerService {
  Future<String> getModelDirectory();
  Future<bool> isDefaultModelReady();
  Future<void> prepareDefaultModel();
}

class ModelManagerServiceImpl implements ModelManagerService {
  @override
  Future<String> getModelDirectory() async {
    final supportDir = await getApplicationSupportDirectory();
    final modelDir = Directory('${supportDir.path}/models/whisper-tiny-es');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return modelDir.path;
  }

  @override
  Future<bool> isDefaultModelReady() async {
    final dir = await getModelDirectory();
    final config = SttModelConfig.whisperTinySpanish(baseDir: dir);
    return config.filesExist;
  }

  @override
  Future<void> prepareDefaultModel() async {
    final dir = await getModelDirectory();
    final config = SttModelConfig.whisperTinySpanish(baseDir: dir);

    if (config.filesExist) {
      return; // Ya está listo en disco
    }

    // Intentar copiar desde los assets pre-empaquetados de la app si están presentes
    final modelFiles = [
      'tiny-encoder.int8.onnx',
      'tiny-decoder.int8.onnx',
      'tokens.txt',
    ];

    for (final fileName in modelFiles) {
      final destFile = File('$dir/$fileName');
      if (!await destFile.exists()) {
        try {
          final byteData = await rootBundle.load('assets/models/whisper-tiny-es/$fileName');
          await destFile.writeAsBytes(
            byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
            flush: true,
          );
        } catch (_) {
          // Si no está en assets, quedará pendiente para descarga
        }
      }
    }
  }
}
