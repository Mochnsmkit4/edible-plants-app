import 'package:flutter/material.dart';

/// Kumpulan warna resmi Edible App.
///
/// Ini adalah pengganti "variabel CSS" di Flutter: satu sumber warna
/// yang dipakai bersama oleh semua layar & widget (header, content, menu,
/// katalog, detail tanaman, dll), supaya tampilan konsisten dan cukup
/// diubah dari SATU tempat ini saja kalau mau ganti tema warna.
class AppColors {
  AppColors._(); // mencegah class ini di-instantiate

  static const primary = Color(0xFF012D1D);
  static const primaryContainer = Color(0xFF1B4332);
  static const onPrimaryContainer = Color(0xFF86AF99);
  static const onPrimary = Color(0xFFFFFFFF);

  static const secondary = Color(0xFF0E6C4A);
  static const secondaryContainer = Color(0xFFA0F4C8);
  static const onSecondaryContainer = Color(0xFF19724F);

  static const surface = Color(0xFFF4FAFD);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEEF5F7);

  static const onSurface = Color(0xFF161D1F);
  static const onSurfaceVariant = Color(0xFF414844);

  static const outline = Color(0xFF717973);
  static const outlineVariant = Color(0xFFC1C8C2);

  static const errorContainer = Color(0xFFFFDAD6);
  static const error = Color(0xFFBA1A1A);

  static const scaffoldBackground = Color(0xFFF8F9F1);
}