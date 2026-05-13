import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color black = Color(0xFF0A0A0A); 
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF121212);
  static const Color accent = Color(0xFF007AFF); // Electric Blue
  static const Color accentLight = Color(0xFF00D2FF);
  
  // Neutral
  static const Color white = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF8E8E93);
  static const Color silver = Color(0xFFC0C0C0);
  
  // Status
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  
  // Gradients
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [background, Color(0xFF1C1C1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
