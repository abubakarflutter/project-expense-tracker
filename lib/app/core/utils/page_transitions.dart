import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Custom page transitions for the app
class PageTransitions {
  /// Fade transition
  static Transition fade = Transition.fadeIn;

  /// Slide from right transition
  static Transition rightToLeft = Transition.rightToLeft;

  /// Slide from bottom transition
  static Transition downToUp = Transition.downToUp;

  /// Zoom transition
  static Transition zoom = Transition.zoom;

  /// Cupertino (iOS style) transition
  static Transition cupertino = Transition.cupertino;

  /// Get transition duration
  static Duration get transitionDuration => const Duration(milliseconds: 300);

  /// Navigate with custom transition
  static Future<T?>? to<T>(
    Widget page, {
    Transition transition = Transition.rightToLeft,
    Duration? duration,
    dynamic arguments,
  }) {
    return Get.to<T>(
      () => page,
      transition: transition,
      duration: duration ?? transitionDuration,
      arguments: arguments,
    );
  }
}
