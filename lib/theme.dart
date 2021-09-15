import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The format to display the dates.
final dateFormatter = DateFormat('dd/MM/yyyy');

/// A function that returns the amount formatted for printing.
final amountFormatter = NumberFormat('########.##€');

final animationDuration = Duration(milliseconds: 200);

/// Handle the appearance of the app.
///
/// This code was adapted from:
/// https://github.com/flutter/gallery/blob/master/lib/themes/gallery_theme_data.dart
class AppThemeData {
  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  static final Color _lightFocusColor = Colors.black;
  static final Color _darkFocusColor = Colors.white;

  //static ThemeData lightThemeData = ThemeData.light();
  static ThemeData lightThemeData = themeData(lightScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      //textTheme: _textTheme,
      // Matches manifest.json colors and background color.
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        //textTheme: _textTheme.apply(bodyColor: colorScheme.onPrimary),
        color: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        brightness: colorScheme.brightness,
      ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      backgroundColor: colorScheme.background,
      canvasColor: colorScheme.surface,
      cardColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      accentColor: colorScheme.primary,
      focusColor: focusColor,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withOpacity(0.80),
          _darkFillColor,
        ),
        //contentTextStyle: _textTheme.subtitle1.apply(color: _darkFillColor),
      ),
    );
  }

  static const ColorScheme lightScheme = ColorScheme(
    primary: Color(0xFF0277bc),
    primaryVariant: Color(0xFF004c8b),
    //58a5ef
    secondary: Color(0xFFffab00),
    secondaryVariant: Color(0xFFc67c00),
    //ffdd4b
    background: Color(0xFFE6EBEB),
    surface: Color(0xFFFAFBFB),
    onBackground: _lightFillColor,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _lightFillColor,
    brightness: Brightness.light,
  );

  static const ColorScheme darkScheme = ColorScheme(
    primary: Color(0xAA4caf50),
    primaryVariant: Color(0xFF087f23),
    secondary: Color(0xFF448aff),
    secondaryVariant: Color(0xFF83b9ff),
    background: Color(0xff20272b),
    surface: Color(0xFF37474f),
    onBackground: _darkFillColor,
    error: _darkFillColor,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
    brightness: Brightness.dark,
  );

  static const _light = FontWeight.w300;
  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

// static final TextTheme _textTheme = TextTheme(
//   // App title
//   headline1: GoogleFonts.chango(fontSize: 60, fontWeight: _semiBold, letterSpacing: -2, color: Color(0xAA4caf50)),
//   // Main title
//   headline2: GoogleFonts.chango(fontSize: 25, fontWeight: _regular, letterSpacing: -1),
//   // Attention title
//   headline3: GoogleFonts.chango(fontSize: 40, fontWeight: _medium, letterSpacing: -1, color: _darkFillColor),
//   headline4: TextStyle(fontSize: 14, fontWeight: _bold),
//   headline5: TextStyle(fontSize: 14, fontWeight: _bold),
//   // Appbar and dialogs
//   headline6: GoogleFonts.chango(fontSize: 20, fontWeight: _light, letterSpacing: -1),
//   // Text fields
//   subtitle1: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
//   subtitle2: TextStyle(fontSize: 14, fontWeight: _bold),
//   // Bold text
//   bodyText1: GoogleFonts.poppins(fontSize: 14.0, fontWeight: _bold),
//   // Normal text
//   bodyText2: GoogleFonts.poppins(fontSize: 14.0, fontWeight: _regular),
//   // Components
//   button: GoogleFonts.poppins(fontSize: 14.0, fontWeight: _regular),
//   caption: GoogleFonts.poppins(fontSize: 14.0, fontWeight: _regular),
//   overline: GoogleFonts.poppins(fontSize: 14.0, fontWeight: _regular),
// );
}
