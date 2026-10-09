import 'package:equatable/equatable.dart';
import 'package:yaml/yaml.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content; // Contenido formateado u organizado por IA
  final String rawTranscription; // Transcripción cruda sin procesar
  final String defaultSection; // 'organized' o 'raw': qué sección se muestra por defecto al abrir
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isPinned;
  final bool isRawTranscription; // true si solo tiene transcripción cruda y falta procesar por IA
  final String? audioPath;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.rawTranscription = '',
    this.defaultSection = 'organized',
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isPinned = false,
    this.isRawTranscription = false,
    this.audioPath,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? rawTranscription,
    String? defaultSection,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isPinned,
    bool? isRawTranscription,
    String? audioPath,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      rawTranscription: rawTranscription ?? this.rawTranscription,
      defaultSection: defaultSection ?? this.defaultSection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isRawTranscription: isRawTranscription ?? this.isRawTranscription,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  /// Convierte la nota a formato Markdown con encabezado YAML Frontmatter
  String toMarkdownFileContent() {
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('id: "$id"');
    buffer.writeln('title: "${title.replaceAll('"', r'\"')}"');
    buffer.writeln('created_at: "${createdAt.toUtc().toIso8601String()}"');
    buffer.writeln('updated_at: "${updatedAt.toUtc().toIso8601String()}"');
    buffer.writeln('pinned: $isPinned');
    buffer.writeln('raw_transcription: $isRawTranscription');
    buffer.writeln('default_section: "$defaultSection"');
    if (audioPath != null && audioPath!.isNotEmpty) {
      buffer.writeln('audio_path: "$audioPath"');
    }
    buffer.writeln('tags:');
    for (final tag in tags) {
      buffer.writeln('  - "$tag"');
    }
    buffer.writeln('---');
    buffer.writeln();

    // Guardar sección cruda si existe
    if (rawTranscription.isNotEmpty) {
      buffer.writeln('<!-- RAW_TRANSCRIPTION_START -->');
      buffer.writeln(rawTranscription);
      buffer.writeln('<!-- RAW_TRANSCRIPTION_END -->');
      buffer.writeln();
    }

    buffer.write(content);
    return buffer.toString();
  }

  /// Parsea un archivo Markdown con Frontmatter YAML a un objeto Note
  factory Note.fromMarkdownFileContent(String fileContent, {String defaultId = ''}) {
    if (!fileContent.startsWith('---')) {
      return Note(
        id: defaultId,
        title: 'Sin título',
        content: fileContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final secondSeparatorIndex = fileContent.indexOf('---', 3);
    if (secondSeparatorIndex == -1) {
      return Note(
        id: defaultId,
        title: 'Sin título',
        content: fileContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final yamlString = fileContent.substring(3, secondSeparatorIndex).trim();
    var bodyContent = fileContent.substring(secondSeparatorIndex + 3).trim();

    // Extraer raw transcription si está presente en el archivo
    String rawTranscription = '';
    const rawStartTag = '<!-- RAW_TRANSCRIPTION_START -->';
    const rawEndTag = '<!-- RAW_TRANSCRIPTION_END -->';
    final startIndex = bodyContent.indexOf(rawStartTag);
    final endIndex = bodyContent.indexOf(rawEndTag);

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      rawTranscription = bodyContent.substring(startIndex + rawStartTag.length, endIndex).trim();
      bodyContent = (bodyContent.substring(0, startIndex) + bodyContent.substring(endIndex + rawEndTag.length)).trim();
    }

    try {
      final yamlDoc = loadYaml(yamlString);
      final id = yamlDoc['id']?.toString() ?? defaultId;
      final title = yamlDoc['title']?.toString() ?? 'Sin título';
      final createdAtStr = yamlDoc['created_at']?.toString();
      final updatedAtStr = yamlDoc['updated_at']?.toString();
      final isPinned = yamlDoc['pinned'] == true;
      final isRawTranscription = yamlDoc['raw_transcription'] == true;
      final defaultSection = yamlDoc['default_section']?.toString() ?? 'organized';
      final audioPath = yamlDoc['audio_path']?.toString();

      final rawTags = yamlDoc['tags'];
      final List<String> tags = [];
      if (rawTags is YamlList) {
        tags.addAll(rawTags.map((e) => e.toString()));
      }

      final createdAt = createdAtStr != null
          ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
          : DateTime.now();

      final updatedAt = updatedAtStr != null
          ? DateTime.tryParse(updatedAtStr) ?? DateTime.now()
          : DateTime.now();

      return Note(
        id: id,
        title: title,
        content: bodyContent,
        rawTranscription: rawTranscription,
        defaultSection: defaultSection,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
        isPinned: isPinned,
        isRawTranscription: isRawTranscription,
        audioPath: audioPath,
      );
    } catch (_) {
      return Note(
        id: defaultId,
        title: 'Nota importada',
        content: bodyContent.isNotEmpty ? bodyContent : fileContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        rawTranscription,
        defaultSection,
        createdAt,
        updatedAt,
        tags,
        isPinned,
        isRawTranscription,
        audioPath,
      ];
}
