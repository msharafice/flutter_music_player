import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
  );

  static const TextStyle trackTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 12,
    color: AppColors.darkTextSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    color: AppColors.primaryLight,
  );
}
