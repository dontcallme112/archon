import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static const _base = TextStyle(
    fontFamily: 'Nunito', // fallback to system sans
    color: AppColors.dark,
  );

  static final h1 = _base.copyWith(fontSize: 24, fontWeight: FontWeight.w800);
  static final h2 = _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700);
  static final h3 = _base.copyWith(fontSize: 17, fontWeight: FontWeight.w700);
  static final h4 = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w600);

  static final bodyLarge = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400);
  static final body = _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400);
  static final bodySmall = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  static final label = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w500);
  static final caption = _base.copyWith(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.grey);

  static final button = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2);
}