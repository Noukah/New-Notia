import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notia/features/notes/domain/models/note.dart';
import 'package:notia/features/notes/presentation/widgets/note_preview_modal.dart';

void main() {
  final testNote = Note(
    id: 'test_1',
    title: 'Nota de Prueba',
    content: 'Contenido organizado por IA',
    rawTranscription: 'audio crudo transcrito sin procesar',
    defaultSection: 'organized',
    createdAt: DateTime(2026, 10, 8),
    updatedAt: DateTime(2026, 10, 8),
  );

  testWidgets('NotePreviewModal renders sections, pin and toolbar', (tester) async {
    Note? updatedNote;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  NotePreviewModal.show(
                    context,
                    note: testNote,
                    onNoteUpdated: (note) => updatedNote = note,
                  );
                },
                child: const Text('Abrir Modal'),
              );
            },
          ),
        ),
      ),
    );

    // Abrir el modal
    await tester.tap(find.text('Abrir Modal'));
    await tester.pumpAndSettle();

    // Verificar presencia de la cabecera
    expect(find.text('Nota de Prueba'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Verificar presencia del pin y toolbar
    expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget); // Sólido porque default es organized
    expect(find.byIcon(Icons.add_rounded), findsOneWidget); // Botón '+'
    expect(find.byIcon(Icons.format_bold_rounded), findsOneWidget);

    // Tocar el botón '+' para abrir el popover
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('audio'), findsOneWidget);
    expect(find.text('pregunta ia'), findsOneWidget);
    expect(find.text('imagen'), findsOneWidget);

    // Cerrar el modal tocando el botón de salida / cerrar
    await tester.tap(find.byTooltip('Cerrar'));
    await tester.pumpAndSettle();

    expect(find.text('Nota de Prueba'), findsNothing);
  });
}
