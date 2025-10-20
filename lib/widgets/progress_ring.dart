import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? child;

  const ProgressRing({
    Key? key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 12,
    this.child,
  }) : super(key: key);

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      _animationController.forward(from: 0);
      _previousProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ProgressRingPainter(
              progress: 1.0,
              strokeWidth: widget.strokeWidth,
              color: theme.colorScheme.surface,
              isBackground: true,
            ),
          ),
          
          // Progress ring
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  color: theme.colorScheme.primary,
                  secondaryColor: theme.colorScheme.secondary,
                ),
              );
            },
          ),
          
          // Child widget (counter display)
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color? secondaryColor;
  final bool isBackground;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    this.secondaryColor,
    this.isBackground = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background paint
    if (isBackground) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, paint);
      return;
    }

    // Progress paint with gradient
    final sweepAngle = 2 * math.pi * progress;
    
    Paint paint;
    if (secondaryColor != null) {
      paint = Paint()
        ..shader = SweepGradient(
          colors: [color, secondaryColor!],
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweepAngle,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
    } else {
      paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
    }

    // Draw arc from top (start at -90 degrees)
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
