import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';
import 'package:peerpicks/app/theme/app_theme_provider.dart';
import 'package:peerpicks/app/theme/app_themes.dart';
import 'package:peerpicks/core/services/sensors/sensor_settings_provider.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/home_screen.dart';
import 'package:peerpicks/features/onboarding/presentation/pages/onboarding_screen.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final Light _light = Light();
  StreamSubscription<int>? _lightSub;
  ProviderSubscription<SensorSettingsState>? _sensorSettingsSubscription;
  final List<int> _luxSamples = [];
  static const int _maxLuxSamples = 5;
  static const int _darkLuxThreshold = 35;
  static const int _lightLuxThreshold = 65;
  DateTime _lastLightUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  ThemeMode? _lastAutoMode;

  @override
  void initState() {
    super.initState();

    _sensorSettingsSubscription = ref.listenManual<SensorSettingsState>(
      sensorSettingsProvider,
      (prev, next) {
        if (prev?.autoThemeByLightEnabled != next.autoThemeByLightEnabled) {
          if (next.autoThemeByLightEnabled) {
            _startLightMonitoring();
          } else {
            _stopLightMonitoring();
          }
        }
      },
    );

    final settings = ref.read(sensorSettingsProvider);
    if (settings.autoThemeByLightEnabled) {
      _startLightMonitoring();
    }
  }

  Future<void> _startLightMonitoring() async {
    if (_lightSub != null) return;

    if (Platform.isIOS) {
      try {
        await _light.requestAuthorization();
      } catch (_) {
        // Ignore authorization errors and fall back to manual mode.
      }
    }

    _lightSub = _light.lightSensorStream.listen(_handleLux, onError: (_) {});
  }

  void _handleLux(int lux) {
    if (!ref.read(sensorSettingsProvider).autoThemeByLightEnabled) return;

    _luxSamples.add(lux);
    if (_luxSamples.length > _maxLuxSamples) {
      _luxSamples.removeAt(0);
    }

    final avgLux = _luxSamples.reduce((a, b) => a + b) / _luxSamples.length;

    final now = DateTime.now();
    if (now.difference(_lastLightUpdate) < const Duration(seconds: 2)) {
      return;
    }

    ThemeMode? targetMode;
    if (avgLux <= _darkLuxThreshold) {
      targetMode = ThemeMode.dark;
    } else if (avgLux >= _lightLuxThreshold) {
      targetMode = ThemeMode.light;
    }

    if (targetMode == null || targetMode == _lastAutoMode) return;

    _lastAutoMode = targetMode;
    _lastLightUpdate = now;
    ref.read(appThemeProvider.notifier).setMode(targetMode);
  }

  void _stopLightMonitoring() {
    _lightSub?.cancel();
    _lightSub = null;
  }

  @override
  void dispose() {
    _sensorSettingsSubscription?.close();
    _stopLightMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Access the session service to check login status
    final sessionService = ref.watch(userSessionServiceProvider);
    final bool loggedIn = sessionService.isLoggedIn();

    // 2. Watch the theme provider for live palette + mode switching
    final themeState = ref.watch(appThemeProvider);

    return MaterialApp(
      title: 'PeerPicks',
      debugShowCheckedModeBanner: false,

      // 3. Theme Configuration — driven by provider
      theme: AppThemes.lightTheme(themeState.palette),
      darkTheme: AppThemes.darkTheme(themeState.palette),
      themeMode: themeState.mode,

      // 4. Conditional Navigation
      home: loggedIn ? const HomeScreen() : const OnboardingScreen(),

      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
