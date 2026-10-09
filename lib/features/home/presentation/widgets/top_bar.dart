import 'package:flutter/material.dart';
import 'package:notia/core/constants/app_icons.dart';
import 'package:notia/core/widgets/app_icon.dart';

class HomeTopBar extends StatelessWidget {
  final VoidCallback onNotesTap;
  final VoidCallback onSettingsTap;

  const HomeTopBar({
    super.key,
    required this.onNotesTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón izquierdo: Biblioteca / Notas (sin recuadro)
          Tooltip(
            message: 'Biblioteca de notas',
            child: IconButton(
              icon: AppIcon(
                assetPath: AppIcons.noteLibrary,
                fallbackIcon: Icons.sticky_note_2_outlined,
                size: 28,
                color: iconColor,
              ),
              onPressed: onNotesTap,
            ),
          ),

          // Botón derecho: Ajustes / Configuración (sin recuadro)
          Tooltip(
            message: 'Ajustes',
            child: IconButton(
              icon: AppIcon(
                assetPath: AppIcons.settings,
                fallbackIcon: Icons.settings_outlined,
                size: 28,
                color: iconColor,
              ),
              onPressed: onSettingsTap,
            ),
          ),
        ],
      ),
    );
  }
}
