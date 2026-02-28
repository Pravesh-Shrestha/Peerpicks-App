import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';

class SensorSettingsState {
  final bool shakeToRefreshEnabled;
  final bool tiltToOpenEnabled;
  final bool autoThemeByLightEnabled;
  final bool gestureTipsSeen;
  final double? brightness;

  const SensorSettingsState({
    this.shakeToRefreshEnabled = true,
    this.tiltToOpenEnabled = true,
    this.autoThemeByLightEnabled = false,
    this.gestureTipsSeen = false,
    this.brightness,
  });

  SensorSettingsState copyWith({
    bool? shakeToRefreshEnabled,
    bool? tiltToOpenEnabled,
    bool? autoThemeByLightEnabled,
    bool? gestureTipsSeen,
    double? brightness,
  }) {
    return SensorSettingsState(
      shakeToRefreshEnabled:
          shakeToRefreshEnabled ?? this.shakeToRefreshEnabled,
      tiltToOpenEnabled: tiltToOpenEnabled ?? this.tiltToOpenEnabled,
      autoThemeByLightEnabled:
          autoThemeByLightEnabled ?? this.autoThemeByLightEnabled,
      gestureTipsSeen: gestureTipsSeen ?? this.gestureTipsSeen,
      brightness: brightness ?? this.brightness,
    );
  }
}

class SensorSettingsNotifier extends Notifier<SensorSettingsState> {
  static const _shakeKey = 'sensor_shake_refresh_enabled';
  static const _tiltKey = 'sensor_tilt_open_enabled';
  static const _autoThemeKey = 'sensor_auto_theme_by_light';
  static const _gestureTipsKey = 'sensor_gesture_tips_seen';
  static const _brightnessKey = 'sensor_brightness_value';

  late SharedPreferences _prefs;

  @override
  SensorSettingsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _load();
  }

  SensorSettingsState _load() {
    return SensorSettingsState(
      shakeToRefreshEnabled: _prefs.getBool(_shakeKey) ?? true,
      tiltToOpenEnabled: _prefs.getBool(_tiltKey) ?? true,
      autoThemeByLightEnabled: _prefs.getBool(_autoThemeKey) ?? false,
      gestureTipsSeen: _prefs.getBool(_gestureTipsKey) ?? false,
      brightness: _prefs.getDouble(_brightnessKey),
    );
  }

  void setShakeToRefreshEnabled(bool value) {
    _prefs.setBool(_shakeKey, value);
    state = state.copyWith(shakeToRefreshEnabled: value);
  }

  void setTiltToOpenEnabled(bool value) {
    _prefs.setBool(_tiltKey, value);
    state = state.copyWith(tiltToOpenEnabled: value);
  }

  void setAutoThemeByLightEnabled(bool value) {
    _prefs.setBool(_autoThemeKey, value);
    state = state.copyWith(autoThemeByLightEnabled: value);
  }

  void setGestureTipsSeen(bool value) {
    _prefs.setBool(_gestureTipsKey, value);
    state = state.copyWith(gestureTipsSeen: value);
  }

  void setBrightness(double value) {
    _prefs.setDouble(_brightnessKey, value);
    state = state.copyWith(brightness: value);
  }

  void clearBrightness() {
    _prefs.remove(_brightnessKey);
    state = state.copyWith(brightness: null);
  }
}

final sensorSettingsProvider =
    NotifierProvider<SensorSettingsNotifier, SensorSettingsState>(
  SensorSettingsNotifier.new,
);
