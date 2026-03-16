import 'package:flutter/material.dart';

abstract class AppColors {
  // Seccion 1 - Primitivos privados
  static const Color _btgBlue900 = Color(0xFF002B5C);
  static const Color _btgBlue700 = Color(0xFF003D82);
  static const Color _btgBlue500 = Color(0xFF0051A8);
  static const Color _btgBlue300 = Color(0xFF4D8FD6);
  static const Color _btgBlue100 = Color(0xFFD6E8FF);

  static const Color _btgGold500 = Color(0xFFC9A84C);
  static const Color _btgGold300 = Color(0xFFE4C97B);

  static const Color _green500 = Color(0xFF22C55E);
  static const Color _green100 = Color(0xFFDCFCE7);
  static const Color _red500 = Color(0xFFEF4444);
  static const Color _red100 = Color(0xFFFEE2E2);
  static const Color _amber500 = Color(0xFFF59E0B);
  static const Color _amber100 = Color(0xFFFEF3C7);

  static const Color _neutral900 = Color(0xFF111827);
  static const Color _neutral700 = Color(0xFF374151);
  static const Color _neutral500 = Color(0xFF6B7280);
  static const Color _neutral300 = Color(0xFFD1D5DB);
  static const Color _neutral100 = Color(0xFFF9FAFB);
  static const Color _white = Color(0xFFFFFFFF);

  // Seccion 2 - Semanticos Light
  static const Color primary = _btgBlue500;
  static const Color primaryDark = _btgBlue900;
  static const Color primaryLight = _btgBlue100;
  static const Color primaryMedium = _btgBlue700;
  static const Color primarySoft = _btgBlue300;

  static const Color accent = _btgGold500;
  static const Color accentLight = _btgGold300;

  static const Color backgroundPrimary = _white;
  static const Color backgroundSecondary = _neutral100;
  static const Color backgroundCard = _white;

  static const Color textPrimary = _neutral900;
  static const Color textTertiary = _neutral700;
  static const Color textSecondary = _neutral500;
  static const Color textOnPrimary = _white;
  static const Color textDisabled = _neutral300;

  static const Color success = _green500;
  static const Color successLight = _green100;

  static const Color error = _red500;
  static const Color errorLight = _red100;

  static const Color warning = _amber500;
  static const Color warningLight = _amber100;

  static const Color border = _neutral300;
  static const Color divider = _neutral300;

  // Seccion 3 - Categorias de fondos
  static const Color fpvCategory = _btgBlue500;
  static const Color fpvCategoryBg = _btgBlue100;

  static const Color ficCategory = _btgGold500;
  static const Color ficCategoryBg = Color(0xFFFFF8E7);
}
