// // lib/app/theme/app_theme.dart
// import 'package:flutter/material.dart';

// class AppTheme {
//   static const Color primaryColor = Color(0xFF6C63FF);
//   static const Color secondaryColor = Color(0xFF03DAC6);
//   static const Color backgroundColor = Color(0xFFF5F5F5);
//   static const Color cardColor = Colors.white;
//   static const Color successColor = Color(0xFF4CAF50);
//   static const Color warningColor = Color(0xFFFF9800);
//   static const Color errorColor = Color(0xFFF44336);
//   static const Color accentColor = Color(0xFFF59E0B);
//   static const Color surfaceColor = Colors.white;

  
//   // Text Colors
//   static const Color textPrimary = Color(0xFF1E293B);
//   static const Color textSecondary = Color(0xFF64748B);
//   static const Color textLight = Color(0xFF94A3B8);

//   // Status Colors
//   static const Color infoColor = Color(0xFF3B82F6);

//   // Gender Colors
//   static const Color maleColor = Color(0xFF3B82F6);
//   static const Color femaleColor = Color(0xFFEC4899);


//   static ThemeData lightTheme = ThemeData(
//     primaryColor: primaryColor, 
//     scaffoldBackgroundColor: backgroundColor,
//     colorScheme: ColorScheme.light(
//       primary: primaryColor,
//       secondary: secondaryColor,
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: primaryColor,
//       elevation: 0,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         color: Colors.white,
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//       ),
//       iconTheme: IconThemeData(color: Colors.white),
//     ),
//     cardTheme: CardThemeData(
//       color: cardColor,
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: primaryColor, width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//     ),
//   );

//   static ThemeData darkTheme = ThemeData.dark().copyWith(
//     primaryColor: primaryColor,
//     scaffoldBackgroundColor: const Color(0xFF121212),
//   );

//   static var maleColor;
// }

// lib/app/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ══════════════════════════════════════════════════════════
  // PRIMARY COLORS
  // ══════════════════════════════════════════════════════════
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF918AFF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // ══════════════════════════════════════════════════════════
  // SECONDARY & ACCENT COLORS
  // ══════════════════════════════════════════════════════════
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFFF59E0B);

  // ══════════════════════════════════════════════════════════
  // BACKGROUND & SURFACE COLORS
  // ══════════════════════════════════════════════════════════
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color scaffoldDarkColor = Color(0xFF121212);
  static const Color cardDarkColor = Color(0xFF1E1E1E);

  // ══════════════════════════════════════════════════════════
  // TEXT COLORS
  // ══════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textWhite = Colors.white;

  // ══════════════════════════════════════════════════════════
  // STATUS COLORS
  // ══════════════════════════════════════════════════════════
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color errorColor = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ══════════════════════════════════════════════════════════
  // GENDER COLORS
  // ══════════════════════════════════════════════════════════
  static const Color maleColor = Color(0xFF3B82F6);
  static const Color maleLight = Color(0xFFDBEAFE);
  static const Color femaleColor = Color(0xFFEC4899);
  static const Color femaleLight = Color(0xFFFCE7F3);

  // ══════════════════════════════════════════════════════════
  // ATTENDANCE COLORS
  // ══════════════════════════════════════════════════════════
  static const Color presentColor = Color(0xFF10B981);
  static const Color presentLight = Color(0xFFD1FAE5);
  static const Color absentColor = Color(0xFFEF4444);
  static const Color absentLight = Color(0xFFFEE2E2);
  static const Color lateColor = Color(0xFFF59E0B);
  static const Color lateLight = Color(0xFFFEF3C7);
  static const Color excusedColor = Color(0xFF6366F1);
  static const Color excusedLight = Color(0xFFE0E7FF);

  // ══════════════════════════════════════════════════════════
  // GRADIENTS
  // ══════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF34D399), successColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFF87171), errorColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF374151), Color(0xFF1F2937)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ══════════════════════════════════════════════════════════
  // SHADOWS
  // ══════════════════════════════════════════════════════════
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ══════════════════════════════════════════════════════════
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 100.0;

  // ══════════════════════════════════════════════════════════
  // SPACING
  // ══════════════════════════════════════════════════════════
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacing3XL = 32.0;

  // ══════════════════════════════════════════════════════════
  // FONT SIZES
  // ══════════════════════════════════════════════════════════
  static const double fontXS = 10.0;
  static const double fontSM = 12.0;
  static const double fontMD = 14.0;
  static const double fontLG = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double font3XL = 24.0;
  static const double font4XL = 28.0;
  static const double font5XL = 32.0;

  // ══════════════════════════════════════════════════════════
  // TEXT STYLES
  // ══════════════════════════════════════════════════════════
  static const TextStyle headingLarge = TextStyle(
    fontSize: font4XL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: font3XL,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: fontXXL,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: fontXL,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: fontLG,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: fontMD,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontLG,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontMD,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSM,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: fontMD,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: fontSM,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: fontXS,
    fontWeight: FontWeight.w500,
    color: textLight,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontXS,
    fontWeight: FontWeight.normal,
    color: textLight,
  );

  // ══════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLight,
      secondary: secondaryColor,
      secondaryContainer: Color(0xFFB2F5EA),
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimary,
      onBackground: textPrimary,
      onError: Colors.white,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMD),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: spacingLG,
        vertical: spacingSM,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingXXL,
          vertical: spacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        textStyle: const TextStyle(
          fontSize: fontLG,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingXXL,
          vertical: spacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        textStyle: const TextStyle(
          fontSize: fontLG,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLG,
          vertical: spacingSM,
        ),
        textStyle: const TextStyle(
          fontSize: fontMD,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingLG,
        vertical: spacingLG,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: fontMD),
      labelStyle: const TextStyle(color: textSecondary, fontSize: fontMD),
      prefixIconColor: Colors.grey.shade600,
      suffixIconColor: Colors.grey.shade600,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      selectedColor: primaryColor.withOpacity(0.15),
      disabledColor: Colors.grey.shade200,
      labelStyle: const TextStyle(color: textPrimary, fontSize: fontSM),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: spacingMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radiusXXL),
        ),
      ),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXL),
      ),
      titleTextStyle: headingSmall,
      contentTextStyle: bodyMedium,
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSM),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Tab Bar Theme
    tabBarTheme: TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: textSecondary,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: fontMD,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: fontMD,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: fontXS,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: fontXS,
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: spacingLG,
    ),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: spacingLG),
      minVerticalPadding: spacingSM,
      iconColor: textSecondary,
      textColor: textPrimary,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 24,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      circularTrackColor: Color(0xFFE8E8E8),
      linearTrackColor: Color(0xFFE8E8E8),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade300;
      }),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXS),
      ),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
    ),
  );

  // ══════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldDarkColor,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryDark,
      secondary: secondaryColor,
      secondaryContainer: Color(0xFF00574B),
      surface: cardDarkColor,
      background: scaffoldDarkColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: cardDarkColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardDarkColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMD),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingXXL,
          vertical: spacingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingLG,
        vertical: spacingLG,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: fontMD),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cardDarkColor,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radiusXXL),
        ),
      ),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: cardDarkColor,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXL),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3A3A3A),
      thickness: 1,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: Colors.white70,
      size: 24,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      circularTrackColor: Color(0xFF3A3A3A),
    ),
  );

  // ══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════
  
  /// Get color based on status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return successColor;
      case 'inactive':
        return warningColor;
      case 'blocked':
        return errorColor;
      case 'pending':
        return infoColor;
      default:
        return textSecondary;
    }
  }

  /// Get color based on attendance status
  static Color getAttendanceColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return presentColor;
      case 'absent':
        return absentColor;
      case 'late':
        return lateColor;
      case 'excused':
        return excusedColor;
      default:
        return textSecondary;
    }
  }

  /// Get light version of attendance color
  static Color getAttendanceLightColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return presentLight;
      case 'absent':
        return absentLight;
      case 'late':
        return lateLight;
      case 'excused':
        return excusedLight;
      default:
        return Colors.grey.shade200;
    }
  }

  /// Get gender color
  static Color getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return maleColor;
      case 'female':
        return femaleColor;
      default:
        return textSecondary;
    }
  }

  /// Get gender light color
  static Color getGenderLightColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return maleLight;
      case 'female':
        return femaleLight;
      default:
        return Colors.grey.shade200;
    }
  }

  /// Get icon for gender
  static IconData getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.person;
    }
  }

  /// Get icon for attendance status
  static IconData getAttendanceIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.schedule;
      case 'excused':
        return Icons.info;
      default:
        return Icons.help_outline;
    }
  }
}