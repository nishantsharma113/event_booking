import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🌈 Base Colors
  static const Color primaryColor = Color(0xFF16A34A); // Turf Green
  static const Color secondaryColor = Color(0xFF2563EB); // Blue Accent
  static const Color backgroundColor = Color(0xFFF9FAFB); // Light Gray
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF111827); // Dark Text
  static const Color hintTextColor = Color(0xFF9CA3AF); // Gray Hint

  // 🧱 Rounded Border Radius
  static const double borderRadius = 12.0;

  // 🎨 Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
    ),
    scaffoldBackgroundColor: backgroundColor,

    // 🧠 Text Theme
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: const TextStyle(color: textColor),
      bodyMedium: const TextStyle(color: textColor),
      bodySmall: const TextStyle(color: textColor),
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    // 📦 Card Theme
    cardTheme: CardThemeData(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 2,
      margin: const EdgeInsets.all(8),
    ),

    // 🧭 AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      iconTheme: IconThemeData(color: textColor),
    ),

    // 🔘 Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 3,
      ),
    ),

    // 🔲 Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),

    // ✏️ Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF3F4F6), // Light Gray
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: hintTextColor),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceColor,
      indicatorColor: primaryColor.withValues(alpha: 0.1),
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 24);
        }
        return const IconThemeData(color: Color(0xFF9CA3AF), size: 24);
      }),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF9CA3AF), // Gray
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      showUnselectedLabels: true,
      elevation: 4,
      type: BottomNavigationBarType.fixed,
    ),

    // 🧱 Divider
    dividerColor: const Color(0xFFE5E7EB),
  );

  // 🌚 Optional Dark Theme
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF1F2937),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
          bodySmall: const TextStyle(color: Colors.white),
          labelLarge: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
  );
}
