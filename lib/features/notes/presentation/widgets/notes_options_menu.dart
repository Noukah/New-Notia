import 'package:flutter/material.dart';

class NotesOptionsMenu extends StatelessWidget {
  final VoidCallback onSelect;
  final VoidCallback onToggleView;
  final VoidCallback onSort;
  final VoidCallback onPinFavoritesToTop;
  final VoidCallback onCreateFolder;
  final bool isGridView;
  final bool areFavoritesOnTop;

  const NotesOptionsMenu({
    super.key,
    required this.onSelect,
    required this.onToggleView,
    required this.onSort,
    required this.onPinFavoritesToTop,
    required this.onCreateFolder,
    required this.isGridView,
    required this.areFavoritesOnTop,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSelect,
    required VoidCallback onToggleView,
    required VoidCallback onSort,
    required VoidCallback onPinFavoritesToTop,
    required VoidCallback onCreateFolder,
    required bool isGridView,
    required bool areFavoritesOnTop,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) => Stack(
        children: [
          Positioned(
            top: 54,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: NotesOptionsMenu(
                onSelect: () {
                  Navigator.pop(ctx);
                  onSelect();
                },
                onToggleView: () {
                  Navigator.pop(ctx);
                  onToggleView();
                },
                onSort: () {
                  Navigator.pop(ctx);
                  onSort();
                },
                onPinFavoritesToTop: () {
                  Navigator.pop(ctx);
                  onPinFavoritesToTop();
                },
                onCreateFolder: () {
                  Navigator.pop(ctx);
                  onCreateFolder();
                },
                isGridView: isGridView,
                areFavoritesOnTop: areFavoritesOnTop,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF7E7A7A), // Fondo gris exacto de la captura de Figma
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. seleccionar
          _buildMenuItem(
            text: 'seleccionar',
            onTap: onSelect,
          ),
          const SizedBox(height: 14),

          // 2. ver
          _buildMenuItem(
            text: isGridView ? 'ver (lista)' : 'ver (cuadrícula)',
            onTap: onToggleView,
          ),
          const SizedBox(height: 14),

          // 3. ordenar
          _buildMenuItem(
            text: 'ordenar',
            onTap: onSort,
          ),
          const SizedBox(height: 14),

          // 4. favoritos arriba
          _buildMenuItem(
            text: areFavoritesOnTop ? 'favoritos arriba ✓' : 'favoritos arriba',
            onTap: onPinFavoritesToTop,
          ),
          const SizedBox(height: 14),

          // 5. nueva carpeta
          _buildMenuItem(
            text: 'nueva carpeta',
            onTap: onCreateFolder,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
