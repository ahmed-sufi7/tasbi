import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Floating footer navigation bar with a centered protruding add button.
///
/// Usage:
/// - Place inside a `Positioned` at the bottom (use safe-area offset).
/// - Provide callbacks for left, center (add), and right buttons.
/// - Optionally tune `navWidth` (default: 65% of screen clamped to 200..280).
class FooterNavBar extends StatelessWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onStatsTap;
  final double? navWidth; // if null, widget will compute a responsive width
  final int activeIndex; // 0 = home, 1 = add, 2 = stats
  final Color backgroundColor;
  final Color iconColor;
  final double height;

  const FooterNavBar({
    Key? key,
    this.onHomeTap,
    this.onAddTap,
    this.onStatsTap,
    this.navWidth,
    this.activeIndex = 0,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.iconColor = Colors.white,
    this.height = 75.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final computedWidth = navWidth ?? (screenWidth * 0.65).clamp(200.0, 280.0);

    // Bar inner height (the rounded black container)
    const barHeight = 58.0;

    return Center(
      child: SizedBox(
        width: computedWidth,
        height: height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background rounded bar
            Container(
              width: computedWidth,
              height: barHeight,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                border: Border.all(
                  color: const Color(0xFF3A3A3A),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Home icon
                    _NavImageButton(
                      activeImage: 'assets/icons/home-active.png',
                      inactiveImage: 'assets/icons/home-inactive.png',
                      onTap: onHomeTap,
                      isActive: activeIndex == 0,
                    ),

                    // Spacing before add button
                    const SizedBox(width: 24),

                    // Placeholder for centered add button spacing
                    const SizedBox(width: 36),

                    // Spacing after add button
                    const SizedBox(width: 24),

                    // Stats icon
                    _NavImageButton(
                      activeImage: 'assets/icons/stats-active.png',
                      inactiveImage: 'assets/icons/stats-inacative.png', // Note: typo in filename
                      onTap: onStatsTap,
                      isActive: activeIndex == 1,
                    ),
                  ],
                ),
              ),
            ),

            // Protruding centered add button
            Positioned(
              top: 0, // protrudes above the bar
              child: GestureDetector(
                onTap: onAddTap,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: backgroundColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.add,
                    color: backgroundColor,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavImageButton extends StatelessWidget {
  final String activeImage;
  final String inactiveImage;
  final VoidCallback? onTap;
  final bool isActive;

  const _NavImageButton({
    Key? key,
    required this.activeImage,
    required this.inactiveImage,
    this.onTap,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        child: Image.asset(
          isActive ? activeImage : inactiveImage,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
