import 'package:flutter/material.dart';
import 'dart:math' as math;

class ClockFaceProgressRing extends StatelessWidget {
  final double progress;
  final double endpointProgress; // Separate progress for the endpoint badge
  final int currentCount;
  final double size;
  final double strokeWidth;
  final bool showClockFace;
  final bool showMilestones;
  final List<int> milestones;
  final Widget? child;

  const ClockFaceProgressRing({
    Key? key,
    required this.progress,
    this.endpointProgress = -1, // -1 means use progress value
    required this.currentCount,
    this.size = 320,
    this.strokeWidth = 24,
    this.showClockFace = true,
    this.showMilestones = true,
    this.milestones = const [100, 300, 500, 1000],
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actualEndpointProgress = endpointProgress >= 0 ? endpointProgress : progress;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150), // Reduced from 1000ms for instant response
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: progress),
      builder: (context, animatedProgress, _) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 150), // Reduced from 1000ms for instant response
          curve: Curves.easeOut,
          tween: Tween<double>(begin: 0, end: actualEndpointProgress),
          builder: (context, animatedEndpointProgress, _) {
            return SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring and clock face
                  CustomPaint(
                    size: Size(size, size),
                    painter: _ClockFacePainter(
                      showClockFace: showClockFace,
                      strokeWidth: strokeWidth,
                    ),
                  ),
                  
                  // Progress ring
                  CustomPaint(
                    size: Size(size, size),
                    painter: _ProgressRingPainter(
                      progress: animatedProgress,
                      endpointProgress: animatedEndpointProgress,
                      strokeWidth: strokeWidth,
                      currentCount: currentCount,
                    ),
                  ),
                  
                  // Milestone badges
                  if (showMilestones)
                    ...milestones.where((m) => currentCount >= m).map((milestone) {
                      return _buildMilestoneBadge(milestone);
                    }),
                  
                  // Center content
                  if (child != null) child!,
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMilestoneBadge(int milestone) {
    // Position badges around the ring based on milestone value
    final angle = (milestone % 100) * (2 * math.pi / 100) - math.pi / 2;
    final radius = size / 2 - strokeWidth - 24;
    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle);

    return Positioned(
      left: size / 2 + x - 20,
      top: size / 2 + y - 20,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1E90FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E90FF).withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.star_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _ClockFacePainter extends CustomPainter {
  final bool showClockFace;
  final double strokeWidth;

  _ClockFacePainter({
    required this.showClockFace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring
    final bgPaint = Paint()
      ..color = const Color(0xFF3A3A3A).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (!showClockFace) return;

    // Draw tick marks (120 ticks)
    for (int i = 0; i < 120; i++) {
      final isMajorTick = i % 10 == 0;
      final angle = (i * 3 - 90) * math.pi / 180;
      
      final tickPaint = Paint()
        ..color = const Color(0xFF2A2A2A).withValues(alpha: 0.4) // opacity 0.4 as per design system
        ..strokeWidth = isMajorTick ? 2 : 1
        ..strokeCap = StrokeCap.round;

      final tickLength = isMajorTick ? 12.0 : 8.0;
      final innerRadius = radius - strokeWidth / 2 - 10; // Increased gap from 4 to 12
      final outerRadius = innerRadius - tickLength;

      final startPoint = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      
      final endPoint = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      canvas.drawLine(startPoint, endPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(_ClockFacePainter oldDelegate) => false;
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double endpointProgress; // Separate progress for endpoint badge position
  final double strokeWidth;
  final int currentCount;

  _ProgressRingPainter({
    required this.progress,
    required this.endpointProgress,
    required this.strokeWidth,
    required this.currentCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Use primary accent color as per design system (#1E90FF)
    final progressPaint = Paint()
      ..color = const Color(0xFF1E90FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2, // Start at 12 o'clock
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Draw dots on the progress ring (layered on top of solid arc)
    final dotCount = 120; // Increased from 60 for more dots
    final dotRadius = 1.5; // Reduced from 3.0 for smaller dots
    final dotPaint = Paint()
      ..color = Colors.white // White dots to stand out on blue arc
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dotCount; i++) {
      final dotProgress = i / dotCount;
      if (dotProgress <= progress) {
        final angle = -math.pi / 2 + (2 * math.pi * dotProgress);
        final dotX = center.dx + radius * math.cos(angle);
        final dotY = center.dy + radius * math.sin(angle);
        
        canvas.drawCircle(
          Offset(dotX, dotY),
          dotRadius,
          dotPaint,
        );
      }
    }
    
    // Draw endpoint badge icon (anchored to progress ring endpoint)
    // Use endpointProgress for badge position so it continues moving
    if (endpointProgress > 0) {
      // Use modulo to keep the angle cycling (handles values > 1.0)
      final normalizedProgress = endpointProgress % 1.0;
      final endAngle = -math.pi / 2 + (2 * math.pi * normalizedProgress);
      final badgeRadius = radius;
      final badgeX = center.dx + badgeRadius * math.cos(endAngle);
      final badgeY = center.dy + badgeRadius * math.sin(endAngle);
      
      // Draw small circular badge
      final badgePaint = Paint()
        ..color = const Color(0xFF1E90FF) // primary_accent
        ..style = PaintingStyle.fill;
      
      // Outer circle (badge container)
      canvas.drawCircle(
        Offset(badgeX, badgeY),
        16, // Reduced size for smaller badge
        badgePaint,
      );
      
      // Inner white circle (icon indicator)
      final iconPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(badgeX, badgeY),
        4, // Reduced for smaller inner dot
        iconPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.endpointProgress != endpointProgress ||
           oldDelegate.currentCount != currentCount;
  }
}
