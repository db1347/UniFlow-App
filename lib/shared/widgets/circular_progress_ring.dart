import 'package:flutter/material.dart';

class CircularProgressRing extends StatelessWidget {
  const CircularProgressRing({
    super.key,
    required this.progress,
    this.size = 280,
    this.strokeWidth = 10,
    this.child,
    this.color,
  });

  final double progress; // 0-1
  final double size;
  final double strokeWidth;
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: progress.clamp(0, 1),
              strokeWidth: strokeWidth,
              color: color ?? theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.15),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Account for the outer blur so the glow isn't clipped at the canvas edge.
    // The blur sigma used below spreads pixels outside the stroke by roughly
    // `blurSigma` pixels; reserve some padding so the effect stays inside
    // the canvas bounds.
    const double blurSigma = 6.0;
    final double blurPadding = blurSigma * 2;
    final radius = (size.shortestSide - strokeWidth - blurPadding) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw a soft colored glow behind the progress arc so the halo is more
    // visible and matches the design reference (colored halo).
    final glowPaint = Paint()
      ..color = color.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, blurSigma * 1.6);

    // Main arc should be sharp and fully colored; keep the blur only on the glow.
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -90 * (3.1415926535 / 180);
    final sweep = progress * 2 * 3.1415926535;

    // Draw glow first, then main arc on top.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
