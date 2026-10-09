import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notia/features/notes/domain/models/note.dart';
import 'package:notia/features/notes/presentation/screens/notes_viewer_screen.dart';
import 'package:notia/features/notes/presentation/widgets/note_card.dart';
import 'package:notia/features/notes/presentation/widgets/search_bottom_bar.dart';
import 'package:notia/features/notes/presentation/widgets/selection_action_bar.dart';

void main() {
  final testNotes = [
    Note(
      id: '1',
      title: 'Nota Primera',
      content: 'Contenido 1',
      createdAt: DateTime(2026, 10, 8),
      updatedAt: DateTime(2026, 10, 8),
      isPinned: true,
      audioPath: 'rec.wav',
    ),
    Note(
      id: '2',
      title: 'Segunda Nota',
      content: 'Contenido 2',
      createdAt: DateTime(2026, 10, 8),
      updatedAt: DateTime(2026, 10, 8),
      isPinned: false,
    ),
  ];

  testWidgets('NotesViewerScreen renders grid view and transforms bar on long press', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotesViewerScreen(initialNotes: testNotes),
      ),
    );

    // Verificar presencia de notas y barra normal de búsqueda
    expect(find.text('Nota Primera'), findsOneWidget);
    expect(find.text('Segunda Nota'), findsOneWidget);
    expect(find.byType(SearchBottomBar), findsOneWidget);
    expect(find.byType(SelectionActionBar), findsNothing);

    // Long press sobre la primera nota
    await tester.longPress(find.text('Nota Primera'));
    await tester.pumpAndSettle();

    // Debe activarse el modo de selección y mostrar la barra de acciones
    expect(find.byType(SelectionActionBar), findsOneWidget);
    expect(find.text('Mover'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);

    // Cancelar selección
    await tester.tap(find.byTooltip('Cancelar selección'));
    await tester.pumpAndSettle();

    // Vuelve a la barra de búsqueda
    expect(find.byType(SearchBottomBar), findsOneWidget);
    expect(find.byType(SelectionActionBar), findsNothing);
  });
}
