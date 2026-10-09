import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatefulWidget {
  final String? assetPath;
  final IconData fallbackIcon;
  final double size;
  final Color? color;

  const AppIcon({
    super.key,
    this.assetPath,
    required this.fallbackIcon,
    this.size = 24.0,
    this.color,
  });

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  bool _assetExists = false;

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  @override
  void didUpdateWidget(covariant AppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _checkAsset();
    }
  }

  Future<void> _checkAsset() async {
    if (widget.assetPath == null) {
      if (mounted) setState(() => _assetExists = false);
      return;
    }

    try {
      await rootBundle.load(widget.assetPath!);
      if (mounted) {
        setState(() => _assetExists = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _assetExists = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_assetExists && widget.assetPath != null) {
      final path = widget.assetPath!;
      if (path.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          path,
          width: widget.size,
          height: widget.size,
          colorFilter: widget.color != null
              ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
              : null,
        );
      } else {
        // PNG, JPG, GIF etc.
        return Image.asset(
          path,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          color: widget.color,
        );
      }
    }

    return Icon(
      widget.fallbackIcon,
      size: widget.size,
      color: widget.color,
    );
  }
}
