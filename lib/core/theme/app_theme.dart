import 'package:flutter/material.dart';

/// 웹툰 다이어리 앱 테마 정의
/// Design Guide 기반 컬러 팔레트 및 TextTheme 정의
class AppTheme {
  // 컬러 정의 (Design Guide 기반)
  
  /// Primary Color: Fresh Mint Green
  static const Color primaryColor = Color(0xFF00D884);
  
  /// Secondary Color: Soft Lilac
  static const Color secondaryColor = Color(0xFFC9A8FF);
  
  /// Accent 1: Peach Pink
  static const Color accent1 = Color(0xFFFF8FB3);
  
  /// Accent 2: Sky Blue
  static const Color accent2 = Color(0xFF7EC8FF);
  
  /// Accent 3: Sunny Yellow
  static const Color accent3 = Color(0xFFFFE36E);
  
  /// Background: White
  static const Color background = Color(0xFFFFFFFF);
  
  /// Background: Off White
  static const Color backgroundOffWhite = Color(0xFFFAFBFF);
  
  /// Surface: Card Surface
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Text Primary
  static const Color textPrimary = Color(0xFF111318);
  
  /// Text Secondary
  static const Color textSecondary = Color(0xFF5B5B66);
  
  /// Line/Divider
  static const Color lineDivider = Color(0xFFEDECF2);
  
  /// Grayscale
  static const Color grayscaleDark = Color(0xFF111318);
  static const Color grayscaleDark2 = Color(0xFF2A2E37);
  static const Color grayscaleMedium = Color(0xFF6B7280);
  static const Color grayscaleLight = Color(0xFFC9CDD6);
  static const Color grayscaleLight2 = Color(0xFFE9ECF2);
  static const Color grayscaleLightest = Color(0xFFF6F7FB);
  
  /// Status Colors
  static const Color success = Color(0xFF00C97A);
  static const Color warning = Color(0xFFFFA500);
  static const Color error = Color(0xFFFF5A5F);
  
  /// App Theme 생성
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundOffWhite,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      cardTheme: _buildCardThemeData(),
      chipTheme: _buildChipTheme(),
      floatingActionButtonTheme: _buildFloatingActionButtonTheme(),
      dividerTheme: _buildDividerTheme(),
    );
  }
  
  /// TextTheme 정의 (Design Guide Type Scale 기반)
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // H1: 28px, Bold, LH 36
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 36 / 28,
        color: textPrimary,
        letterSpacing: 0,
      ),
      // H2: 24px, SemiBold, LH 32
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: textPrimary,
        letterSpacing: 0,
      ),
      // H3: 20px, SemiBold, LH 28
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: textPrimary,
        letterSpacing: 0,
      ),
      // Subtitle: 18px, Medium, LH 26
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 26 / 18,
        color: textPrimary,
        letterSpacing: 0,
      ),
      // Body 1: 16px, Regular, LH 24
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 24 / 16,
        color: textPrimary,
        letterSpacing: 0,
      ),
      // Body 2: 14px, Regular, LH 22
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 22 / 14,
        color: textPrimary,
        letterSpacing: 0,
      ),
      // Caption: 12-13px, Regular, LH 18
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 18 / 12,
        color: textSecondary,
        letterSpacing: 0,
      ),
      // Button: 16px, SemiBold, LH 20
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 20 / 16,
        color: textPrimary,
        letterSpacing: 0,
      ),
      // Number tag(뱃지): 12px, SemiBold
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 18 / 12,
        color: textPrimary,
        letterSpacing: 0,
      ),
    );
  }
  
  /// AppBar Theme
  static AppBarTheme _buildAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
  
  /// ElevatedButton Theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 20 / 16,
        ),
      ),
    );
  }
  
  /// OutlinedButton Theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: secondaryColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 20 / 16,
        ),
      ),
    );
  }
  
  /// TextButton Theme
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 20 / 16,
        ),
      ),
    );
  }
  
  /// InputDecoration Theme
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lineDivider, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lineDivider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: textSecondary.withValues(alpha: 0.6),
        fontSize: 16,
      ),
      errorStyle: const TextStyle(
        color: error,
        fontSize: 12,
      ),
    );
  }
  
  /// Card Theme
  static CardThemeData _buildCardThemeData() {
    return CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      // 그림자 레벨 1: 0,4,12 / #000 10%
      // Flutter에서는 elevation 대신 boxShadow를 직접 사용
    );
  }
  
  /// Chip Theme
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: grayscaleLightest,
      selectedColor: secondaryColor.withValues(alpha: 0.1),
      disabledColor: grayscaleLight2,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
    );
  }
  
  /// FloatingActionButton Theme
  static FloatingActionButtonThemeData _buildFloatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      // Size: 56x56, 코너 28
    );
  }
  
  /// Divider Theme
  static DividerThemeData _buildDividerTheme() {
    return const DividerThemeData(
      color: lineDivider,
      thickness: 1,
      space: 1,
    );
  }
}

