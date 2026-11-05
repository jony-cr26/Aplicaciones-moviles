import 'package:flutter/material.dart';

class AppTheme {
  static const _guinda = Color(0xFF6C1D45); // IPN
  static const _azul = Color(0xFF0B5CAB); // ESCOM

  static ThemeData construir(String tema, Brightness brillo) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: tema == 'azul' ? _azul : _guinda,
          brightness: brillo,
        ),
      );
}