import 'package:flutter/material.dart';
import 'package:peerpicks/app/theme/app_theme_provider.dart';

/// Central palette registry.  Every palette supplies two [ThemeData] objects
/// (light + dark) so the app can switch mode instantly.
class AppThemes {
  AppThemes._();

  // ── Palette metadata (used in settings UI) ──────────────────
  static const Map<AppThemePalette, PaletteMeta> paletteMeta = {
    AppThemePalette.peerpicks: PaletteMeta(
      label: 'PeerPicks',
      description: 'The original lime-green brand',
      previewColors: [Color(0xFFB4D333), Color(0xFF75A638), Color(0xFF333333)],
    ),
    AppThemePalette.ocean: PaletteMeta(
      label: 'Ocean',
      description: 'Cool blue tones',
      previewColors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF01579B)],
    ),
    AppThemePalette.sunset: PaletteMeta(
      label: 'Sunset',
      description: 'Warm orange & coral',
      previewColors: [Color(0xFFFFB74D), Color(0xFFFF7043), Color(0xFFBF360C)],
    ),
    AppThemePalette.berry: PaletteMeta(
      label: 'Berry',
      description: 'Deep purple & pink',
      previewColors: [Color(0xFFBA68C8), Color(0xFF7B1FA2), Color(0xFF4A148C)],
    ),
    AppThemePalette.midnight: PaletteMeta(
      label: 'Midnight',
      description: 'Elegant grey & slate',
      previewColors: [Color(0xFF90A4AE), Color(0xFF546E7A), Color(0xFF263238)],
    ),
  };

  // ── Resolve ThemeData ────────────────────────────────────────
  static ThemeData lightTheme(AppThemePalette palette) {
    switch (palette) {
      case AppThemePalette.peerpicks:
        return _peerpicksLight;
      case AppThemePalette.ocean:
        return _oceanLight;
      case AppThemePalette.sunset:
        return _sunsetLight;
      case AppThemePalette.berry:
        return _berryLight;
      case AppThemePalette.midnight:
        return _midnightLight;
    }
  }

  static ThemeData darkTheme(AppThemePalette palette) {
    switch (palette) {
      case AppThemePalette.peerpicks:
        return _peerpicksDark;
      case AppThemePalette.ocean:
        return _oceanDark;
      case AppThemePalette.sunset:
        return _sunsetDark;
      case AppThemePalette.berry:
        return _berryDark;
      case AppThemePalette.midnight:
        return _midnightDark;
    }
  }

  // ════════════════════════════════════════════════════════════
  //  PEERPICKS  (lime-green brand)
  // ════════════════════════════════════════════════════════════
  static final _peerpicksLight = _buildLight(
    seed: const Color(0xFF75A638),
    primary: const Color(0xFF75A638),
    secondary: const Color(0xFFB4D333),
    surface: Colors.white,
    background: const Color(0xFFF9FAF5),
  );

  static final _peerpicksDark = _buildDark(
    seed: const Color(0xFF75A638),
    primary: const Color(0xFFB4D333),
    secondary: const Color(0xFF75A638),
    surface: const Color(0xFF1A1C18),
    background: const Color(0xFF121410),
  );

  // ════════════════════════════════════════════════════════════
  //  OCEAN  (blue)
  // ════════════════════════════════════════════════════════════
  static final _oceanLight = _buildLight(
    seed: const Color(0xFF0288D1),
    primary: const Color(0xFF0288D1),
    secondary: const Color(0xFF4FC3F7),
    surface: Colors.white,
    background: const Color(0xFFF5F9FC),
  );

  static final _oceanDark = _buildDark(
    seed: const Color(0xFF0288D1),
    primary: const Color(0xFF4FC3F7),
    secondary: const Color(0xFF0288D1),
    surface: const Color(0xFF15202B),
    background: const Color(0xFF0D1821),
  );

  // ════════════════════════════════════════════════════════════
  //  SUNSET  (orange-coral)
  // ════════════════════════════════════════════════════════════
  static final _sunsetLight = _buildLight(
    seed: const Color(0xFFFF7043),
    primary: const Color(0xFFE64A19),
    secondary: const Color(0xFFFFB74D),
    surface: Colors.white,
    background: const Color(0xFFFFF8F3),
  );

  static final _sunsetDark = _buildDark(
    seed: const Color(0xFFFF7043),
    primary: const Color(0xFFFF8A65),
    secondary: const Color(0xFFE64A19),
    surface: const Color(0xFF1F1610),
    background: const Color(0xFF16100B),
  );

  // ════════════════════════════════════════════════════════════
  //  BERRY  (purple)
  // ════════════════════════════════════════════════════════════
  static final _berryLight = _buildLight(
    seed: const Color(0xFF7B1FA2),
    primary: const Color(0xFF7B1FA2),
    secondary: const Color(0xFFBA68C8),
    surface: Colors.white,
    background: const Color(0xFFFAF5FC),
  );

  static final _berryDark = _buildDark(
    seed: const Color(0xFF7B1FA2),
    primary: const Color(0xFFCE93D8),
    secondary: const Color(0xFF7B1FA2),
    surface: const Color(0xFF1C1520),
    background: const Color(0xFF130E17),
  );

  // ════════════════════════════════════════════════════════════
  //  MIDNIGHT  (slate grey-blue)
  // ════════════════════════════════════════════════════════════
  static final _midnightLight = _buildLight(
    seed: const Color(0xFF546E7A),
    primary: const Color(0xFF37474F),
    secondary: const Color(0xFF90A4AE),
    surface: Colors.white,
    background: const Color(0xFFF5F7F8),
  );

  static final _midnightDark = _buildDark(
    seed: const Color(0xFF546E7A),
    primary: const Color(0xFF90A4AE),
    secondary: const Color(0xFF546E7A),
    surface: const Color(0xFF1B2226),
    background: const Color(0xFF11171A),
  );

  // ════════════════════════════════════════════════════════════
  //  BUILDERS
  // ════════════════════════════════════════════════════════════
  static ThemeData _buildLight({
    required Color seed,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color background,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.grey[400]),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? primary.withOpacity(0.4)
                : Colors.grey[300]),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey[200], thickness: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  static ThemeData _buildDark({
    required Color seed,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color background,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      primary: primary,
      secondary: secondary,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(
          color: Colors.grey[400],
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.grey[600]),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? primary.withOpacity(0.4)
                : Colors.grey[700]),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey[800], thickness: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}

// ─── Palette Metadata (for UI) ───────────────────────────────
class PaletteMeta {
  final String label;
  final String description;
  final List<Color> previewColors;

  const PaletteMeta({
    required this.label,
    required this.description,
    required this.previewColors,
  });
}
