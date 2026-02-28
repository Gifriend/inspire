import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspire/core/assets/fonts.gen.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';

class BaseTheme {
  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: BaseColor.primaryInspire,
    primary: BaseColor.primaryInspire,
    secondary: BaseColor.primaryInspire2,
    surface: BaseColor.white,
    error: BaseColor.error,
    brightness: Brightness.light,
  );

  static ThemeData appTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: BaseColor.neutral.shade0,
    fontFamily: FontFamily.openSans,
    colorScheme: _colorScheme,
    primaryColor: BaseColor.primaryInspire,
    cardColor: BaseColor.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _colorScheme.primary,
        foregroundColor: _colorScheme.onPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: BaseColor.white,
      surfaceTintColor: BaseColor.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: BaseColor.black,
        statusBarBrightness: Brightness.light,
        statusBarColor: BaseColor.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}

