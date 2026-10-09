import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notia/core/theme/app_theme.dart';
import 'package:notia/features/notes/domain/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isGridView;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.isGridView,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFFD6D6D6) : Colors.white;
    const textColor = Colors.black87;

    final dateFormat = DateFormat('dd/MM/yy');
    final formattedDate = dateFormat.format(note.updatedAt);
    final hasAudio = note.audioPath != null && note.audioPath!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14.0),
        child: isGridView
            ? _buildGridContent(formattedDate, hasAudio, textColor)
            : _buildListContent(formattedDate, hasAudio, textColor),
      ),
    );
  }

  Widget _buildGridContent(String formattedDate, bool hasAudio, Color textColor) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Título y Estrella de favorito
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Sin título',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.isPinned)
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF2C94C), // Dorado favorito
                    size: 20,
                  ),
              ],
            ),

            const Spacer(),

            // Pie: Punto rojo de audio y Fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Punto rojo: solo si es transcripción cruda sin procesar por IA
                if (note.isRawTranscription)
                  Tooltip(
                    message: 'Transcripción cruda (sin procesar por IA)',
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.recordRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 10),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Círculo morado central de Selección
        if (isSelected)
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF8E8CD8).withValues(alpha: 0.9), // Círculo morado de Figma
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListContent(String formattedDate, bool hasAudio, Color textColor) {
    return Row(
      children: [
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF8E8CD8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note.title.isNotEmpty ? note.title : 'Sin título',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF2C94C),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (note.isRawTranscription)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.recordRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Transcripción cruda',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.recordRed.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
