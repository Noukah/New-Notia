import 'package:flutter/material.dart';
import 'package:notia/core/constants/app_icons.dart';
import 'package:notia/core/theme/app_theme.dart';
import 'package:notia/core/widgets/app_icon.dart';

class RecordingControlsBar extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;
  final bool isPaused;

  const RecordingControlsBar({
    super.key,
    required this.onDiscard,
    required this.onPauseResume,
    required this.onStop,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dockBg = isDark ? const Color(0xFFD6D6D6) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: dockBg,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Descartar / Basurero
          Tooltip(
            message: 'Descartar grabación',
            child: IconButton(
              icon: const AppIcon(
                assetPath: AppIcons.trash,
                fallbackIcon: Icons.delete_outline_rounded,
                size: 28,
              ),
              onPressed: onDiscard,
            ),
          ),

          // 2. Pausa / Reanudar
          Tooltip(
            message: isPaused ? 'Reanudar' : 'Pausar',
            child: IconButton(
              icon: AppIcon(
                assetPath: isPaused ? AppIcons.play : AppIcons.pause,
                fallbackIcon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 30,
              ),
              onPressed: onPauseResume,
            ),
          ),

          // 3. Detener / Guardar (Hecho / Done)
          Tooltip(
            message: 'Detener y transcribir',
            child: GestureDetector(
              onTap: onStop,
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const AppIcon(
                  assetPath: AppIcons.done,
                  fallbackIcon: Icons.check_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
