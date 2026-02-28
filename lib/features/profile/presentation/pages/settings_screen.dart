import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/app/theme/app_theme_provider.dart';
import 'package:peerpicks/app/theme/app_themes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(appThemeProvider);
    final meta = AppThemes.paletteMeta[themeState.palette]!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String modeLabel() {
      switch (themeState.mode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System';
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Account ──
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Name, email, date of birth',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Password & Security',
            subtitle: 'Change password, two-factor auth',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.email_outlined,
            title: 'Email Preferences',
            subtitle: 'Marketing, newsletters, updates',
            onTap: () {},
          ),
          const Divider(height: 1),

          // ── Appearance ──
          _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Color Palette',
            subtitle: meta.label,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final c in meta.previewColors)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
            onTap: () => _showPaletteSheet(context, ref, themeState.palette),
          ),
          _SettingsTile(
            icon: Icons.brightness_6_outlined,
            title: 'Theme Mode',
            subtitle: modeLabel(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    modeLabel(),
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
            onTap: () => _showModeSheet(context, ref, themeState.mode),
          ),
          _SettingsTile(
            icon: Icons.text_fields_rounded,
            title: 'Font Size',
            subtitle: 'Default',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          const Divider(height: 1),

          // ── Notifications ──
          _SectionHeader(title: 'Notifications'),
          _SwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Likes, comments, follows',
            value: true,
            onChanged: (_) {},
          ),
          _SwitchTile(
            icon: Icons.mark_email_unread_outlined,
            title: 'Email Notifications',
            subtitle: 'Weekly digest, recommendations',
            value: false,
            onChanged: (_) {},
          ),
          _SwitchTile(
            icon: Icons.vibration_rounded,
            title: 'In-App Sounds',
            subtitle: 'Notification sounds and haptics',
            value: true,
            onChanged: (_) {},
          ),
          const Divider(height: 1),

          // ── Privacy ──
          _SectionHeader(title: 'Privacy'),
          _SwitchTile(
            icon: Icons.visibility_outlined,
            title: 'Private Account',
            subtitle: 'Only followers can see your picks',
            value: false,
            onChanged: (_) {},
          ),
          _SettingsTile(
            icon: Icons.block_outlined,
            title: 'Blocked Users',
            subtitle: 'Manage blocked accounts',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.history_rounded,
            title: 'Activity Status',
            subtitle: 'Show when you\'re active',
            onTap: () {},
          ),
          const Divider(height: 1),

          // ── Permissions ──
          _SectionHeader(title: 'Permissions'),
          _SettingsTile(
            icon: Icons.camera_alt_outlined,
            title: 'Camera',
            subtitle: 'Allow access for photos and videos',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.photo_library_outlined,
            title: 'Photos',
            subtitle: 'Allow access to your photo library',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: 'Allow location for nearby picks',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.mic_outlined,
            title: 'Microphone',
            subtitle: 'Allow for video recording',
            onTap: () {},
          ),
          const Divider(height: 1),

          // ── Data & Storage ──
          _SectionHeader(title: 'Data & Storage'),
          _SettingsTile(
            icon: Icons.storage_rounded,
            title: 'Storage Usage',
            subtitle: 'Cached images, downloads',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Auto-Download Media',
            subtitle: 'Wi-Fi only',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Clear Cache',
            subtitle: 'Free up space on your device',
            onTap: () => _showClearCacheDialog(context),
          ),
          const Divider(height: 1),

          // ── About ──
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0 (Build 1)',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.code_rounded,
            title: 'Open Source Licenses',
            subtitle: 'Third-party libraries',
            onTap: () {},
          ),
          const SizedBox(height: 32),

          // Danger zone
          Center(
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context),
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Palette Picker ──────────────────────────────────────────
  void _showPaletteSheet(
    BuildContext context,
    WidgetRef ref,
    AppThemePalette current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Palette',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...AppThemePalette.values.map((p) {
              final meta = AppThemes.paletteMeta[p]!;
              final selected = p == current;
              return _PaletteOptionTile(
                meta: meta,
                selected: selected,
                onTap: () {
                  ref.read(appThemeProvider.notifier).setPalette(p);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Mode Picker ─────────────────────────────────────────────
  void _showModeSheet(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme Mode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _ModeOptionTile(
                label: 'Light',
                icon: Icons.wb_sunny_outlined,
                selected: current == ThemeMode.light,
                accentColor: cs.primary,
                onTap: () {
                  ref.read(appThemeProvider.notifier).setMode(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              _ModeOptionTile(
                label: 'Dark',
                icon: Icons.dark_mode_outlined,
                selected: current == ThemeMode.dark,
                accentColor: cs.primary,
                onTap: () {
                  ref.read(appThemeProvider.notifier).setMode(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
              _ModeOptionTile(
                label: 'System Default',
                icon: Icons.settings_brightness,
                selected: current == ThemeMode.system,
                accentColor: cs.primary,
                onTap: () {
                  ref.read(appThemeProvider.notifier).setMode(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove cached images and temporary files. Your account data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. All your picks, comments, and data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Settings Tile ───────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface.withOpacity(0.8)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: cs.onSurface.withOpacity(0.45),
        ),
      ),
      trailing:
          trailing ?? Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

// ─── Switch Tile ─────────────────────────────────────────────
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface.withOpacity(0.8)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: cs.onSurface.withOpacity(0.45),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: cs.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

// ─── Palette Option Tile ─────────────────────────────────────
class _PaletteOptionTile extends StatelessWidget {
  final PaletteMeta meta;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteOptionTile({
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in meta.previewColors)
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? cs.primary : Colors.transparent,
                  width: selected ? 2 : 0,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        meta.label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        meta.description,
        style: TextStyle(
          fontSize: 12,
          color: cs.onSurface.withOpacity(0.45),
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: cs.primary)
          : null,
    );
  }
}

// ─── Mode Option Tile ────────────────────────────────────────
class _ModeOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ModeOptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? accentColor : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: accentColor)
          : null,
      onTap: onTap,
    );
  }
}
