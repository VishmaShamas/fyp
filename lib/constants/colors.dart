import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD896FF);
  static const Color white = Color(0xFFFEFEFE);
  static const Color backroundColor = Color(0xFF2D3047);
  static const Color lightAccentColor = Color(0xFFF4E5F7);
  static const Color greyColor = Color(0XFF939999);
  static const Color lightPrimary = Color(0xFF181059);
  static Color samiDarkColor = const Color(0XFF313333);
  static Color blackColor = const Color(0XFF000000);
  static const Color lightCardColor = Color.fromARGB(106, 250, 250, 250);
  static const Color darkScaffoldColor = Color.fromARGB(255, 9, 3, 27);
  static const Color darkPrimary = Color.fromARGB(255, 94, 75, 236);
  static LinearGradient customOnBoardingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [const Color(0xFF110C1D).withValues(alpha: 0.0), const Color(0xFF110C1D)],
  );
  static const pinkColor = Color(0XFFfb6e63);
  static Color cardBackgroundColor = Color(0xFF2A2D3E);
  static Color textSecondaryColor = Color(0xFFA1A4B2);
  static Color dividerColor = Color(0xFF3A3E52);
}
