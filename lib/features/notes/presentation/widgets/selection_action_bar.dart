import 'package:flutter/material.dart';
import 'package:notia/core/constants/app_icons.dart';
import 'package:notia/core/widgets/app_icon.dart';

class SelectionActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onMove;
  final VoidCallback onLock;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onMore;
  final VoidCallback onCancel;

  const SelectionActionBar({
    super.key,
    required this.selectedCount,
    required this.onMove,
    required this.onLock,
    required this.onShare,
    required this.onDelete,
    required this.onMore,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Negro / oscuro mate de Figma
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Mover
          _buildActionButton(
            icon: Icons.drive_file_move_outline,
            label: 'Mover',
            onTap: onMove,
          ),

          // 2. Bloquear
          _buildActionButton(
            icon: Icons.lock_outline_rounded,
            label: 'Bloquear',
            onTap: onLock,
          ),

          // 3. Compartir
          _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Compartir',
            onTap: onShare,
          ),

          // 4. Eliminar (Basura)
          _buildActionButton(
            assetPath: AppIcons.trash,
            fallbackIcon: Icons.delete_outline_rounded,
            label: 'Eliminar',
            color: Colors.redAccent,
            onTap: onDelete,
          ),

          // 5. Más
          _buildActionButton(
            icon: Icons.more_vert_rounded,
            label: 'Más',
            onTap: onMore,
          ),

          // 6. Cancelar selección (X)
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
            onPressed: onCancel,
            tooltip: 'Cancelar selección',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    String? assetPath,
    IconData? fallbackIcon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assetPath != null && fallbackIcon != null)
            AppIcon(
              assetPath: assetPath,
              fallbackIcon: fallbackIcon,
              size: 22,
              color: color,
            )
          else if (icon != null)
            Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
