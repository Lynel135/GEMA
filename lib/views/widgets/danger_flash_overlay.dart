import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Overlay merah berkedip (1 detik per siklus: merah → memudar → merah).
class DangerFlashOverlay extends StatefulWidget {
  const DangerFlashOverlay({super.key});

  @override
  State<DangerFlashOverlay> createState() => _DangerFlashOverlayState();
}

class _DangerFlashOverlayState extends State<DangerFlashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _opacity = Tween<double>(begin: 0.72, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, child) {
          return Container(
            color: AppTheme.dangerColor.withValues(alpha: _opacity.value),
          );
        },
      ),
    );
  }
}
