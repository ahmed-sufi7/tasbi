import 'package:flutter/material.dart';

class CounterButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const CounterButton({
    Key? key,
    required this.onTap,
    this.size = 140,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 15),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 48,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
