import 'package:flutter/material.dart';
import 'package:notia/core/constants/app_icons.dart';
import 'package:notia/core/theme/app_theme.dart';
import 'package:notia/core/widgets/app_icon.dart';

class DualCircleSwitcher extends StatefulWidget {
  final int activeIndex; // 0 = Audio / Voz, 1 = Escritura manual
  final Function(int newIndex) onIndexChanged;
  final VoidCallback onSingleTap;
  final VoidCallback onDoubleTap;
  final bool isRecording;
  final Duration recordingDuration;

  const DualCircleSwitcher({
    super.key,
    required this.activeIndex,
    required this.onIndexChanged,
    required this.onSingleTap,
    required this.onDoubleTap,
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
  });

  @override
  State<DualCircleSwitcher> createState() => _DualCircleSwitcherState();
}

class _DualCircleSwitcherState extends State<DualCircleSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleSwipe(DragEndDetails details) {
    if (widget.isRecording) return; // Bloquear swipe durante grabación activa

    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -100) {
      // Swipe hacia la izquierda
      if (widget.activeIndex == 0) widget.onIndexChanged(1);
    } else if (velocity > 100) {
      // Swipe hacia la derecha
      if (widget.activeIndex == 1) widget.onIndexChanged(0);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleFrontColor = isDark ? AppTheme.darkCircleFront : AppTheme.lightCircleFront;
    final circleBackColor = isDark ? AppTheme.darkCircleBack : AppTheme.lightCircleBack;

    const double circleSize = 230.0;
    const double stackWidth = 320.0;
    const double stackHeight = 260.0;

    final isAudioActive = widget.activeIndex == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contenedor GestureDetector para swipes y taps
        GestureDetector(
          onHorizontalDragEnd: _handleSwipe,
          onTap: widget.onSingleTap,
          onDoubleTap: widget.onDoubleTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: stackWidth,
            height: stackHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Círculo Trasero (Profundidad / Fondo)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  left: isAudioActive ? 75 : 15,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 320),
                    scale: 0.88,
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: circleBackColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(4, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isAudioActive
                            ? const AppIcon(
                                assetPath: AppIcons.newNote,
                                fallbackIcon: Icons.edit_note_rounded,
                                size: 48,
                                color: Colors.black38,
                              )
                            : const Icon(
                                Icons.mic_none_rounded,
                                size: 48,
                                color: Colors.black38,
                              ),
                      ),
                    ),
                  ),
                ),

                // 2. Círculo Delantero (Modo Activo Principal)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  left: isAudioActive ? 15 : 75,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final pulseScale = widget.isRecording
                          ? 1.0 + (_pulseController.value * 0.05)
                          : 1.0;

                      return Transform.scale(
                        scale: pulseScale,
                        child: Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            color: circleFrontColor,
                            shape: BoxShape.circle,
                            border: widget.isRecording
                                ? Border.all(
                                    color: AppTheme.recordRed.withValues(
                                      alpha: 0.6 + (_pulseController.value * 0.4),
                                    ),
                                    width: 4,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: widget.isRecording
                                    ? AppTheme.recordRed.withValues(alpha: 0.35)
                                    : Colors.black.withValues(alpha: 0.25),
                                blurRadius: widget.isRecording ? 24 : 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: widget.isRecording
                                ? _buildRecordingContent()
                                : _buildActiveModeContent(isAudioActive),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. Paginación Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(isActive: widget.activeIndex == 0),
            const SizedBox(width: 8),
            _buildDot(isActive: widget.activeIndex == 1),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveModeContent(bool isAudio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isAudio
            ? const Icon(
                Icons.mic_rounded,
                size: 64,
                color: Colors.black87,
              )
            : const AppIcon(
                assetPath: AppIcons.newNote,
                fallbackIcon: Icons.edit_note_rounded,
                size: 64,
                color: Colors.black87,
              ),
        const SizedBox(height: 8),
        Text(
          isAudio ? 'Grabar voz' : 'Escribir nota',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isAudio ? 'Doble tap para iniciar' : 'Doble tap para escribir',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.graphic_eq_rounded,
          size: 60,
          color: AppTheme.recordRed,
        ),
        const SizedBox(height: 8),
        Text(
          _formatDuration(widget.recordingDuration),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.recordRed,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Grabando...',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
