import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notia/features/notes/domain/models/note.dart';

class NotePreviewModal extends StatefulWidget {
  final Note note;
  final Function(Note updatedNote) onNoteUpdated;
  final VoidCallback? onProcessWithAi;

  const NotePreviewModal({
    super.key,
    required this.note,
    required this.onNoteUpdated,
    this.onProcessWithAi,
  });

  static Future<void> show(
    BuildContext context, {
    required Note note,
    required Function(Note updatedNote) onNoteUpdated,
    VoidCallback? onProcessWithAi,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar vista previa',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) {
        return NotePreviewModal(
          note: note,
          onNoteUpdated: onNoteUpdated,
          onProcessWithAi: onProcessWithAi,
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<NotePreviewModal> createState() => _NotePreviewModalState();
}

class _NotePreviewModalState extends State<NotePreviewModal> {
  late Note _currentNote;
  late PageController _pageController;
  int _currentPage = 0;
  bool _showPlusMenu = false;

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _rawController;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;

    // Abrir en la sección fijada como predeterminada
    _currentPage = _currentNote.defaultSection == 'raw' ? 0 : 1;
    _pageController = PageController(initialPage: _currentPage);

    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: _currentNote.content);
    _rawController = TextEditingController(
      text: _currentNote.rawTranscription.isNotEmpty
          ? _currentNote.rawTranscription
          : _currentNote.content,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _rawController.dispose();
    super.dispose();
  }

  void _togglePinnedSection() {
    setState(() {
      final newDefault = _currentPage == 0 ? 'raw' : 'organized';
      _currentNote = _currentNote.copyWith(defaultSection: newDefault);
      widget.onNoteUpdated(_currentNote);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentPage == 0
              ? '📌 Transcripción cruda fijada como vista inicial'
              : '📌 Nota organizada fijada como vista inicial',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _insertFormatting(String prefix, [String suffix = '']) {
    final controller = _currentPage == 0 ? _rawController : _contentController;
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid) {
      controller.text = '$text$prefix$suffix';
      return;
    }

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix${selection.textInside(text)}$suffix',
    );
    controller.text = newText;
  }

  void _insertCheckbox() {
    _insertFormatting('\n- [ ] ');
  }

  void _showAllToolsSheet() {
    setState(() => _showPlusMenu = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20.0),
          children: [
            const Center(
              child: Text(
                'Herramientas de Edición',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 24),
            // 1. Listas y Tareas (Organización Activa)
            _buildCategorySection('1. Listas y Tareas (Organización Activa)', [
              _buildToolTile('🔘 Casilla de verificación / Checkbox', 'Inserta casilla interactiva para marcar tareas', () {
                _insertCheckbox();
                Navigator.pop(ctx);
              }),
              _buildToolTile('⚫ Lista con viñetas', 'Puntos tradicionales para estructurar ideas', () {
                _insertFormatting('\n• ');
                Navigator.pop(ctx);
              }),
              _buildToolTile('🔢 Lista numerada', 'Secuencia numérica automática paso a paso', () {
                _insertFormatting('\n1. ');
                Navigator.pop(ctx);
              }),
              _buildToolTile('➡️ Aumentar sangría', 'Mueve el texto a la derecha (subnivel)', () {
                _insertFormatting('    ');
                Navigator.pop(ctx);
              }),
              _buildToolTile('⬅️ Reducir sangría', 'Mueve el texto hacia la izquierda', () {
                final c = _currentPage == 0 ? _rawController : _contentController;
                if (c.text.startsWith('    ')) {
                  c.text = c.text.substring(4);
                }
                Navigator.pop(ctx);
              }),
            ]),

            // 2. Formato de Texto y Tipografía
            _buildCategorySection('2. Formato de Texto y Tipografía', [
              _buildToolTile('Aa Estilos rápidos', 'Título, Encabezado, Subtítulo o Cuerpo', () {
                _insertFormatting('\n### ');
                Navigator.pop(ctx);
              }),
              _buildToolTile('B Negrita / Bold', 'Resalta texto importante', () {
                _insertFormatting('**', '**');
                Navigator.pop(ctx);
              }),
              _buildToolTile('I Cursiva / Italic', 'Estiliza citas o palabras', () {
                _insertFormatting('*', '*');
                Navigator.pop(ctx);
              }),
              _buildToolTile('U Subrayado', 'Destaca frases clave', () {
                _insertFormatting('<u>', '</u>');
                Navigator.pop(ctx);
              }),
              _buildToolTile('S Tachado', 'Cruza el texto con una línea para descartar', () {
                _insertFormatting('~~', '~~');
                Navigator.pop(ctx);
              }),
              _buildToolTile('🎨 Color de fuente', 'Cambia el color de la letra', () {
                _insertFormatting('<span style="color:blue">', '</span>');
                Navigator.pop(ctx);
              }),
              _buildToolTile('🖌️ Resaltador / Marcador', 'Fondo de color detrás de las letras', () {
                _insertFormatting('==', '==');
                Navigator.pop(ctx);
              }),
            ]),

            // 3. Inserción de Multimedia y Archivos
            _buildCategorySection('3. Inserción de Multimedia y Archivos', [
              _buildToolTile('📷 Cámara / Escáner', 'Tomar foto directa o escanear documentos y PDFs', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo cámara/escáner...')),
                );
              }),
              _buildToolTile('🖼️ Galería / Archivos', 'Insertar fotos, videos o documentos', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo selector de archivos...')),
                );
              }),
              _buildToolTile('📎 Hipervínculo / Enlace', 'Añade URLs web o enlace a otra nota interna', () {
                _insertFormatting('[Enlace](https://...)');
                Navigator.pop(ctx);
              }),
              _buildToolTile('🎙️ Nota de voz / Audio', 'Graba audio y genera transcripción automática', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Iniciando grabación de voz en la nota...')),
                );
              }),
              _buildToolTile('📅 Fecha y Hora', 'Marca de tiempo exacta con un toque', () {
                _insertFormatting(' [${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}] ');
                Navigator.pop(ctx);
              }),
            ]),

            // 4. Herramientas de Dibujo y Escritura a Mano
            _buildCategorySection('4. Herramientas de Dibujo y Escritura a Mano', [
              _buildToolTile('✏️ Lápiz / Bolígrafo', 'Dibujar o tomar apuntes a mano alzada', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lienzo de dibujo / mano alzada activado')),
                );
              }),
              _buildToolTile('🖋️ Pluma estilográfica', 'Trazos caligráficos sensibles a la presión', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modo pluma caligráfica')),
                );
              }),
              _buildToolTile('🧽 Borrador', 'Elimina trazos realizados a mano', () {
                Navigator.pop(ctx);
              }),
              _buildToolTile('⬡ Lazo de selección', 'Rodear trazos para mover, duplicar o redimensionar', () {
                Navigator.pop(ctx);
              }),
            ]),

            // 5. Edición Estructural y Tablas
            _buildCategorySection('5. Edición Estructural y Tablas', [
              _buildToolTile('📊 Insertar Tabla', 'Cuadrícula de filas y columnas para datos', () {
                _insertFormatting('\n| Columna 1 | Columna 2 |\n|---|---|\n| Dato 1 | Dato 2 |\n');
                Navigator.pop(ctx);
              }),
              _buildToolTile('➖ Línea divisoria', 'Separador horizontal entre secciones', () {
                _insertFormatting('\n---\n');
                Navigator.pop(ctx);
              }),
              _buildToolTile('🗂️ Bloques colapsables', 'Plegar/desplegar párrafos bajo un encabezado', () {
                _insertFormatting('\n<details><summary>Título de sección</summary>\nContenido colapsable...\n</details>\n');
                Navigator.pop(ctx);
              }),
            ]),

            // 6. Control del Sistema (Esquinas de la Barra)
            _buildCategorySection('6. Control del Sistema', [
              _buildToolTile('↩️ Deshacer (Undo)', 'Revierte el último cambio realizado', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deshacer última acción')),
                );
              }),
              _buildToolTile('↪️ Rehacer (Redo)', 'Recupera lo que habías borrado con deshacer', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rehacer última acción')),
                );
              }),
              _buildToolTile('🔍 Buscador (Lupa)', 'Localiza palabras exactas en el texto', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Búsqueda dentro de la nota')),
                );
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildToolTile(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yy');
    final formattedDate = dateFormat.format(_currentNote.updatedAt);

    final isCurrentPagePinned = (_currentPage == 0 && _currentNote.defaultSection == 'raw') ||
        (_currentPage == 1 && _currentNote.defaultSection == 'organized');

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            height: MediaQuery.of(context).size.height * 0.78,
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
            decoration: BoxDecoration(
              color: const Color(0xFFE4E4E4), // Fondo de tarjeta de Figma
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // 1. Cabecera (Título, Fecha y botón X para salir)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 14, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Título',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) {
                                _currentNote = _currentNote.copyWith(title: val);
                                widget.onNoteUpdated(_currentNote);
                              },
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Botón 'x para salir' de Figma
                          Tooltip(
                            message: 'Cerrar',
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.black87, size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Colors.black12),

                    // 2. Cuerpo: PageView con las secciones (Cruda vs Organizada)
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (idx) {
                          setState(() {
                            _currentPage = idx;
                            _showPlusMenu = false;
                          });
                        },
                        children: [
                          // Página 0: Transcripción Cruda
                          _buildPageSection(
                            badgeText: 'Transcripción Cruda (Sherpa ONNX)',
                            badgeColor: Colors.deepOrangeAccent,
                            controller: _rawController,
                            hintText: 'Aquí se guarda la transcripción directa del audio...',
                            showAiAction: true,
                          ),

                          // Página 1: Nota Organizada por IA
                          _buildPageSection(
                            badgeText: 'Nota Organizada',
                            badgeColor: Colors.indigoAccent,
                            controller: _contentController,
                            hintText: 'Escribe aquí o visualiza la nota estructurada con IA...',
                            showAiAction: false,
                          ),
                        ],
                      ),
                    ),

                    // 3. Indicador de Pin y Paginación Dots
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pin / Chincheta (Sólido si está fijado por defecto, Hueco si no)
                          Tooltip(
                            message: isCurrentPagePinned
                                ? 'Sección fijada como vista por defecto al abrir'
                                : 'Toca para fijar esta sección como vista por defecto',
                            child: GestureDetector(
                              onTap: _togglePinnedSection,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isCurrentPagePinned
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCurrentPagePinned
                                      ? Icons.push_pin_rounded // Color sólido
                                      : Icons.push_pin_outlined, // Hueco
                                  color: isCurrentPagePinned
                                      ? const Color(0xFFE53935) // Rojo sólido de Figma
                                      : Colors.black38,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Paginación dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(_currentPage == 0),
                              const SizedBox(width: 6),
                              _buildDot(_currentPage == 1),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 4. Barra de Herramientas Inferior (Píldora con botón '+')
                    _buildBottomToolbar(),
                  ],
                ),

                // 5. Menú Popover del botón '+' (audio, pregunta ia, imagen)
                if (_showPlusMenu)
                  Positioned(
                    bottom: 74,
                    right: 24,
                    child: _buildPlusMenuPopover(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageSection({
    required String badgeText,
    required Color badgeColor,
    required TextEditingController controller,
    required String hintText,
    required bool showAiAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
              if (showAiAction)
                TextButton.icon(
                  onPressed: () {
                    if (widget.onProcessWithAi != null) {
                      widget.onProcessWithAi!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Procesando transcripción con IA...')),
                      );
                    }
                  },
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Estructurar con IA', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                if (_currentPage == 0) {
                  _currentNote = _currentNote.copyWith(rawTranscription: val);
                } else {
                  _currentNote = _currentNote.copyWith(content: val);
                }
                widget.onNoteUpdated(_currentNote);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFC7C7C7), // Barra gris alargada de Figma
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Acciones de formato rápido
          IconButton(
            icon: const Icon(Icons.check_box_outlined, color: Colors.black87, size: 20),
            tooltip: 'Casilla de verificación',
            onPressed: _insertCheckbox,
          ),
          IconButton(
            icon: const Icon(Icons.format_bold_rounded, color: Colors.black87, size: 20),
            tooltip: 'Negrita',
            onPressed: () => _insertFormatting('**', '**'),
          ),
          IconButton(
            icon: const Icon(Icons.format_italic_rounded, color: Colors.black87, size: 20),
            tooltip: 'Cursiva',
            onPressed: () => _insertFormatting('*', '*'),
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted_rounded, color: Colors.black87, size: 20),
            tooltip: 'Lista con viñetas',
            onPressed: () => _insertFormatting('\n• '),
          ),
          IconButton(
            icon: const Icon(Icons.title_rounded, color: Colors.black87, size: 20),
            tooltip: 'Estilo de título',
            onPressed: () => _insertFormatting('\n## '),
          ),

          const Spacer(),

          // Botón '+' con popover (Imagen 1 de Figma)
          GestureDetector(
            onTap: () {
              setState(() => _showPlusMenu = !_showPlusMenu);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                _showPlusMenu ? Icons.close_rounded : Icons.add_rounded,
                color: Colors.black87,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlusMenuPopover() {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPopoverItem('audio', Icons.mic_none_rounded, () {
            setState(() => _showPlusMenu = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Adjuntar / Grabar audio')),
            );
          }),
          _buildPopoverItem('pregunta ia', Icons.auto_awesome, () {
            setState(() => _showPlusMenu = false);
            if (widget.onProcessWithAi != null) {
              widget.onProcessWithAi!();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Consulta rápida con Inteligencia Artificial')),
              );
            }
          }),
          _buildPopoverItem('imagen', Icons.image_outlined, () {
            setState(() => _showPlusMenu = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Insertar imagen desde galería o cámara')),
            );
          }),
          const Divider(height: 12),
          _buildPopoverItem('más opciones', Icons.more_horiz_rounded, _showAllToolsSheet),
        ],
      ),
    );
  }

  Widget _buildPopoverItem(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.black87 : Colors.black26,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
