import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de colores base
  static const Color primaryBlue = Color(0xFF2F80ED); // Azul del botón '+'
  static const Color accentYellow = Color(0xFFF2C94C); // Amarillo carpeta de importar
  static const Color recordRed = Color(0xFFEB5757); // Rojo grabación / descartar

  // Fondos y Superficies Modo Oscuro (basado en Figma)
  static const Color darkBackground = Color(0xFF2C2C2C); // Gris oscuro del lienzo
  static const Color darkCircleFront = Color(0xFFD6D6D6); // Círculo principal claro
  static const Color darkCircleBack = Color(0xFF756F6F);  // Círculo secundario fondo
  static const Color darkDockPill = Color(0xFFD9D9D9);    // Barra flotante táctil
  static const Color darkSurface = Color(0xFF383838);
  static const Color darkSquareButton = Color(0xFFD6D6D6);

  // Fondos y Superficies Modo Claro
  static const Color lightBackground = Color(0xFFF2F4F7);
  static const Color lightCircleFront = Color(0xFFFFFFFF);
  static const Color lightCircleBack = Color(0xFFD0D5DD);
  static const Color lightDockPill = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSquareButton = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      fontFamily: GoogleFonts.figtree().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        surface: lightSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: GoogleFonts.figtree().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),
    );
  }
}
