import 'package:flutter_test/flutter_test.dart';
import 'package:notia/features/notes/domain/models/note.dart';

void main() {
  group('Note Model Tests', () {
    test('serializes and deserializes markdown with frontmatter correctly', () {
      final originalNote = Note(
        id: 'test-note-1',
        title: 'Reunión de Notia',
        content: 'Este es el cuerpo de la nota con **markdown**.',
        rawTranscription: 'hola este es el audio transcrito sin procesar',
        defaultSection: 'raw',
        createdAt: DateTime.utc(2026, 10, 8, 16, 0, 0),
        updatedAt: DateTime.utc(2026, 10, 8, 16, 30, 0),
        tags: const ['ia', 'audio'],
        isPinned: true,
        isRawTranscription: true,
        audioPath: 'recordings/test.wav',
      );

      final markdown = originalNote.toMarkdownFileContent();
      final parsedNote = Note.fromMarkdownFileContent(markdown);

      expect(parsedNote.id, equals(originalNote.id));
      expect(parsedNote.title, equals(originalNote.title));
      expect(parsedNote.content, equals(originalNote.content));
      expect(parsedNote.rawTranscription, equals(originalNote.rawTranscription));
      expect(parsedNote.defaultSection, equals('raw'));
      expect(parsedNote.createdAt, equals(originalNote.createdAt));
      expect(parsedNote.updatedAt, equals(originalNote.updatedAt));
      expect(parsedNote.tags, equals(['ia', 'audio']));
      expect(parsedNote.isPinned, isTrue);
      expect(parsedNote.isRawTranscription, isTrue);
      expect(parsedNote.audioPath, equals('recordings/test.wav'));
    });
  });
}
