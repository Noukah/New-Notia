import 'package:flutter/material.dart';
import 'package:notia/features/notes/domain/models/note.dart';
import 'package:notia/features/notes/presentation/widgets/filter_chips_bar.dart';
import 'package:notia/features/notes/presentation/widgets/note_card.dart';
import 'package:notia/features/notes/presentation/widgets/note_preview_modal.dart';
import 'package:notia/features/notes/presentation/widgets/notes_options_menu.dart';
import 'package:notia/features/notes/presentation/widgets/search_bottom_bar.dart';
import 'package:notia/features/notes/presentation/widgets/selection_action_bar.dart';

class NotesViewerScreen extends StatefulWidget {
  final List<Note>? initialNotes;

  const NotesViewerScreen({
    super.key,
    this.initialNotes,
  });

  @override
  State<NotesViewerScreen> createState() => _NotesViewerScreenState();
}

class _NotesViewerScreenState extends State<NotesViewerScreen> {
  late List<Note> _notes;
  bool _isGridView = true; // true = Cuadrícula (2 cols), false = Lista (1 col)
  String _activeFilter = 'todos';
  final Set<String> _selectedNoteIds = {};
  bool _isSelectionMode = false;
  bool _areFavoritesOnTop = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showScrollToTop = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _notes = widget.initialNotes ?? _createSampleNotes();

    _scrollController.addListener(() {
      if (_scrollController.offset > 140 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 140 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleNoteSelection(String noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNoteIds.add(noteId);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedNoteIds.clear();
      _isSelectionMode = false;
    });
  }

  void _showCreateNoteSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Crear Nueva Nota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.redAccent),
                ),
                title: const Text('Nota de voz'),
                subtitle: const Text('Grabar audio y transcribir con Sherpa ONNX'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Volver a Home para grabar
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                ),
                title: const Text('Nota escrita a mano'),
                subtitle: const Text('Redactar texto directamente en Markdown'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abriendo editor de texto...')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    NotesOptionsMenu.show(
      context,
      isGridView: _isGridView,
      areFavoritesOnTop: _areFavoritesOnTop,
      onSelect: () {
        setState(() => _isSelectionMode = true);
      },
      onToggleView: () {
        setState(() => _isGridView = !_isGridView);
      },
      onSort: _showSortDialog,
      onPinFavoritesToTop: () {
        setState(() {
          _areFavoritesOnTop = !_areFavoritesOnTop;
          if (_areFavoritesOnTop) {
            _notes.sort((a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0));
          } else {
            _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_areFavoritesOnTop
                ? 'Favoritos colocados al inicio'
                : 'Orden normal restaurado'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      onCreateFolder: _showNewFolderDialog,
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Ordenar notas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: const Text('Fecha más reciente'),
              onTap: () {
                setState(() => _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Fecha más antigua'),
              onTap: () {
                setState(() => _notes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt)));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha_rounded),
              title: const Text('Título (A - Z)'),
              onTap: () {
                setState(() => _notes.sort((a, b) => a.title.compareTo(b.title)));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewFolderDialog() {
    final folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva carpeta'),
        content: TextField(
          controller: folderController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la carpeta',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = folderController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Carpeta "$name" creada.')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  List<Note> _getFilteredNotes() {
    return _notes.where((note) {
      // Filtro de búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = note.title.toLowerCase().contains(query);
        final matchesContent = note.content.toLowerCase().contains(query);
        if (!matchesTitle && !matchesContent) return false;
      }

      // Filtro de categorías
      switch (_activeFilter) {
        case 'fav':
          return note.isPinned;
        case 'voz':
          return note.audioPath != null && note.audioPath!.isNotEmpty;
        case 'escrita':
          return note.audioPath == null || note.audioPath!.isEmpty;
        case 'borrador':
          return note.isRawTranscription || note.title == 'Sin título';
        case 'pap':
          return false; // Papelera vacía en demo
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _getFilteredNotes();

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C), // Fondo obscuro Figma
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Barra superior: Volver a Home y Menú de opciones
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        _isSelectionMode
                            ? '${_selectedNoteIds.length} seleccionada${_selectedNoteIds.length > 1 ? 's' : ''}'
                            : 'Mis Notas',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 26),
                        onPressed: _showOptionsMenu,
                      ),
                    ],
                  ),
                ),

                // 2. Carrusel de Filtros horizontales
                FilterChipsBar(
                  activeFilter: _activeFilter,
                  onFilterSelected: (filter) {
                    setState(() => _activeFilter = filter);
                  },
                ),

                const SizedBox(height: 12),

                // 3. Área de Notas (Cuadrícula o Lista)
                Expanded(
                  child: filteredNotes.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay notas en esta sección',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        )
                      : _isGridView
                          ? _buildGridView(filteredNotes)
                          : _buildListView(filteredNotes),
                ),

                // 4. Espacio para la barra inferior flotante
                const SizedBox(height: 70),
              ],
            ),

            // 5. Flecha hacia arriba (Scroll al top) - Centrada sobre la barra de búsqueda
            Positioned(
              bottom: 84,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showScrollToTop ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _showScrollToTop
                      ? GestureDetector(
                          onTap: _scrollToTop,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6D6D6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Colors.black87,
                              size: 30,
                            ),
                          ),
                        )
                      : const SizedBox(width: 44, height: 44),
                ),
              ),
            ),

            // 6. Botón Naranja (Crear nota rápida) - Anclado fijamente al lado derecho
            Positioned(
              bottom: 84,
              right: 24,
              child: Tooltip(
                message: 'Crear nota rápida',
                child: GestureDetector(
                  onTap: _showCreateNoteSheet,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE67E22), // Naranja exacto de Figma
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

            // 6. Barra Inferior Transformable (Buscar vs Barra de Acciones)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _isSelectionMode
                    ? SelectionActionBar(
                        key: const ValueKey('selection_bar'),
                        selectedCount: _selectedNoteIds.length,
                        onMove: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mover notas a carpeta...')),
                          );
                        },
                        onLock: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bloquear notas seleccionadas')),
                          );
                        },
                        onShare: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Compartir notas...')),
                          );
                        },
                        onDelete: () {
                          setState(() {
                            _notes.removeWhere((n) => _selectedNoteIds.contains(n.id));
                            _exitSelectionMode();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notas eliminadas.')),
                          );
                        },
                        onMore: _showOptionsMenu,
                        onCancel: _exitSelectionMode,
                      )
                    : SearchBottomBar(
                        key: const ValueKey('search_bar'),
                        searchController: _searchController,
                        onChanged: (val) {
                          setState(() => _searchQuery = val);
                        },
                        onClear: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNotePreview(Note note) {
    NotePreviewModal.show(
      context,
      note: note,
      onNoteUpdated: (updatedNote) {
        setState(() {
          final idx = _notes.indexWhere((n) => n.id == updatedNote.id);
          if (idx != -1) {
            _notes[idx] = updatedNote;
          }
        });
      },
      onProcessWithAi: () => _processNoteWithAi(note),
    );
  }

  void _processNoteWithAi(Note note) {
    final rawText = note.rawTranscription.isNotEmpty ? note.rawTranscription : note.content;
    final structuredContent = '''### 📌 Resumen Estructurado por IA
$rawText

#### 🎯 Puntos Clave
- Transcripción procesada y estructurada automáticamente.
- Formato limpio optimizado según el perfil seleccionado.

#### ✅ Acciones Pendientes
- [ ] Revisar notas clave
- [ ] Archivar o exportar''';

    final updated = note.copyWith(
      content: structuredContent,
      isRawTranscription: false,
      defaultSection: 'organized',
      updatedAt: DateTime.now(),
    );

    setState(() {
      final idx = _notes.indexWhere((n) => n.id == note.id);
      if (idx != -1) {
        _notes[idx] = updated;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Nota organizada con Inteligencia Artificial'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 14.0,
        childAspectRatio: 0.95,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = _selectedNoteIds.contains(note.id);

        return NoteCard(
          note: note,
          isGridView: true,
          isSelected: isSelected,
          onTap: () {
            if (_isSelectionMode) {
              _toggleNoteSelection(note.id);
            } else {
              _openNotePreview(note);
            }
          },
          onLongPress: () {
            _toggleNoteSelection(note.id);
          },
        );
      },
    );
  }

  Widget _buildListView(List<Note> notes) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = _selectedNoteIds.contains(note.id);

        return SizedBox(
          height: 100,
          child: NoteCard(
            note: note,
            isGridView: false,
            isSelected: isSelected,
            onTap: () {
              if (_isSelectionMode) {
                _toggleNoteSelection(note.id);
              } else {
                _openNotePreview(note);
              }
            },
            onLongPress: () {
              _toggleNoteSelection(note.id);
            },
          ),
        );
      },
    );
  }

  List<Note> _createSampleNotes() {
    return [
      Note(
        id: '1',
        title: 'Sin título',
        content: 'Apuntes iniciales...',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        isPinned: true,
        isRawTranscription: true, // 🔴 Transcripción cruda sin procesar por IA
        audioPath: 'rec_1.wav',
      ),
      Note(
        id: '2',
        title: 'Reunión de Notia',
        content: 'Acuerdos de diseño y sincronización...',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isPinned: false,
        isRawTranscription: false, // Ya procesada por IA
        audioPath: 'rec_2.wav',
      ),
      Note(
        id: '3',
        title: 'Sin título',
        content: 'Borrador rápido...',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        isPinned: true,
        isRawTranscription: true, // 🔴 Transcripción cruda sin procesar por IA
        audioPath: 'rec_3.wav',
      ),
      Note(
        id: '4',
        title: 'Ideas de Proyecto',
        content: 'Lluvia de ideas de interfaz...',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isPinned: false,
        isRawTranscription: false, // Nota escrita manual
        audioPath: null,
      ),
      Note(
        id: '5',
        title: 'Sin título',
        content: 'Otra nota rápida...',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: false,
        isRawTranscription: false,
        audioPath: null,
      ),
      Note(
        id: '6',
        title: 'Clase de Arquitectura',
        content: 'Clean architecture y Flutter...',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: false,
        isRawTranscription: true, // 🔴 Transcripción cruda
        audioPath: 'rec_6.wav',
      ),
    ];
  }
}
