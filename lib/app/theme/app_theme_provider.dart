import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';

// ─── Theme Palette Names ─────────────────────────────────────
enum AppThemePalette {
  peerpicks, // default lime-green brand
  ocean, // deep blue
  sunset, // warm orange
  berry, // purple-pink
  midnight, // grey-blue monochrome
}

// ─── Persisted Theme State ───────────────────────────────────
class AppThemeState {
  final ThemeMode mode;
  final AppThemePalette palette;

  const AppThemeState({
    this.mode = ThemeMode.system,
    this.palette = AppThemePalette.peerpicks,
  });

  AppThemeState copyWith({ThemeMode? mode, AppThemePalette? palette}) {
    return AppThemeState(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
    );
  }
}

// ─── Theme Notifier ──────────────────────────────────────────
class AppThemeNotifier extends Notifier<AppThemeState> {
  static const _modeKey = 'app_theme_mode';
  static const _paletteKey = 'app_theme_palette';

  late SharedPreferences _prefs;

  @override
  AppThemeState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _load();
  }

  AppThemeState _load() {
    final modeIndex = _prefs.getInt(_modeKey) ?? 0; // 0 = system
    final paletteIndex = _prefs.getInt(_paletteKey) ?? 0; // 0 = peerpicks

    return AppThemeState(
      mode: ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)],
      palette: AppThemePalette
          .values[paletteIndex.clamp(0, AppThemePalette.values.length - 1)],
    );
  }

  void setMode(ThemeMode mode) {
    _prefs.setInt(_modeKey, mode.index);
    state = state.copyWith(mode: mode);
  }

  void setPalette(AppThemePalette palette) {
    _prefs.setInt(_paletteKey, palette.index);
    state = state.copyWith(palette: palette);
  }
}

final appThemeProvider =
    NotifierProvider<AppThemeNotifier, AppThemeState>(AppThemeNotifier.new);
