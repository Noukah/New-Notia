import 'package:flutter/material.dart';
import 'package:notia/core/constants/app_icons.dart';
import 'package:notia/core/widgets/app_icon.dart';

class FloatingDock extends StatelessWidget {
  final VoidCallback onCreateFolderTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSearchTap;
  final VoidCallback onImportAudioTap;

  const FloatingDock({
    super.key,
    required this.onCreateFolderTap,
    required this.onNotificationsTap,
    required this.onSearchTap,
    required this.onImportAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dockBg = isDark ? const Color(0xFFD6D6D6) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: dockBg,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Botón con '+' (Crear carpeta o grupo - sin fondo azul, solo icono)
          Tooltip(
            message: 'Crear carpeta o grupos',
            child: IconButton(
              icon: const AppIcon(
                assetPath: AppIcons.createFolder,
                fallbackIcon: Icons.add_rounded,
                size: 28,
                color: Colors.black87,
              ),
              onPressed: onCreateFolderTap,
            ),
          ),

          // 2. Icono de campana / recordatorio (Notificaciones)
          Tooltip(
            message: 'Notificaciones',
            child: IconButton(
              icon: const AppIcon(
                assetPath: AppIcons.notifications,
                fallbackIcon: Icons.notifications_none_rounded,
                size: 28,
                color: Colors.black87,
              ),
              onPressed: onNotificationsTap,
            ),
          ),

          // 3. Icono de lupa (Buscar notas)
          Tooltip(
            message: 'Buscar notas',
            child: IconButton(
              icon: const AppIcon(
                assetPath: AppIcons.search,
                fallbackIcon: Icons.search_rounded,
                size: 28,
                color: Colors.black87,
              ),
              onPressed: onSearchTap,
            ),
          ),

          // 4. Icono de carpeta (Subir/importar archivo de audio externo)
          Tooltip(
            message: 'Importar archivo de audio externo',
            child: IconButton(
              icon: const AppIcon(
                assetPath: AppIcons.importAudio,
                fallbackIcon: Icons.folder_rounded,
                size: 30,
              ),
              onPressed: onImportAudioTap,
            ),
          ),
        ],
      ),
    );
  }
}
