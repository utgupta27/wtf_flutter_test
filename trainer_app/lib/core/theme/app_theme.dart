import 'package:flutter/material.dart';

abstract class AppColors {
  static const primary = Color(0xFFE50914);
  static const memberPrimary = Color(0xFF1769E0);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF57F17);
  static const error = Color(0xFFB71C1C);
}

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      );
}
