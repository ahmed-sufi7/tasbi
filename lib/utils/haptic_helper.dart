import 'package:flutter/services.dart';

class HapticHelper {
  // Light haptic feedback
  static void light() {
    HapticFeedback.lightImpact();
  }

  // Medium haptic feedback
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  // Heavy haptic feedback
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  // Selection haptic feedback
  static void selection() {
    HapticFeedback.selectionClick();
  }

  // Vibrate (for counter increment)
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  // Success feedback
  static void success() {
    HapticFeedback.mediumImpact();
  }

  // Error feedback
  static void error() {
    HapticFeedback.heavyImpact();
  }
}
