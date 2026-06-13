import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color kYellow = Color(0xFFF5FF00); // electric yellow
  static const Color kBlack = Color(0xFF000000); // on-yellow text/icons
  static const Color kBackground = Color(
    0xFF0A0A0A,
  ); // main scaffold background
  static const Color kSurface = Color(0xFF141414); // cards, bottom sheets
  static const Color kSurfaceAlt = Color(
    0xFF1F1F1F,
  ); // input fill, elevated surface
  static const Color kBorder = Color(0xFF2A2A2A); // dividers, inactive borders
  static const Color kTextPrimary = Color(
    0xFFFFFFFF,
  ); // primary text on dark bg
  static const Color kTextSecondary = Color(
    0xFF888888,
  ); // hints, subtitles, muted text
  static const Color kError = Color(0xFFFF4D4D); // error states
  static const Color kSuccess = Color(
    0xFF00C853,
  ); // KYC approved, verified badge
}
