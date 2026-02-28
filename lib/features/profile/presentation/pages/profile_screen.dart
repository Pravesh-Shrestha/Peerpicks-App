import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/app/routes/app_routes.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/core/widgets/logout_dialog.dart';
import 'package:peerpicks/features/auth/presentation/state/auth_state.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/picks/presentation/state/picks_state.dart';
import 'package:peerpicks/features/picks/presentation/view_model/picks_viewmodel.dart';
import 'package:peerpicks/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:peerpicks/features/profile/presentation/pages/places_rated_screen.dart';
import 'package:peerpicks/features/profile/presentation/pages/privacy_policy_screen.dart';
import 'package:peerpicks/features/profile/presentation/pages/settings_screen.dart';
import 'package:peerpicks/features/profile/presentation/pages/terms_conditions_screen.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const Color peerLime = Color(0xFFB4D333);

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchMyProfile);
  }

  void _fetchMyProfile() {
    final userId = ref.read(userSessionServiceProvider).getCurrentUserId();
    if (userId != null) {
      ref.read(picksViewModelProvider.notifier).getUserProfileWithPicks(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to navigate on logout
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        AppRoutes.navigateToSignInAfterLogout(context, const SignInScreen());
      }
    });

    final cs = Theme.of(context).colorScheme;
    final userSession = ref.watch(userSessionServiceProvider);
    final userName = userSession.getCurrentUserFullName() ?? 'Guest User';
    final userEmail = userSession.getCurrentUserEmail() ?? 'guest@example.com';
    final picksState = ref.watch(picksViewModelProvider);
    final profile = picksState.viewedUserProfile;

    // Use server data if available
    final followerCount = profile?['followerCount'] ?? 0;
    final followingCount = profile?['followingCount'] ?? 0;
    final picksCount = picksState.status == PicksStatus.loaded
        ? picksState.picks.length
        : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: cs.onPrimary),
          onPressed: () {},
        ),
        title: Text(
          'My Profile',
          style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward, color: cs.onPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Top Section ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 60,
                  width: double.infinity,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  child: _buildProfileCard(
                    context,
                    userName,
                    userEmail,
                    followerCount,
                    followingCount,
                    picksCount,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 160),

            // ── Menu Items ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.grid_view_rounded,
                    title: 'My Places & Picks',
                    onTap: () =>
                        AppRoutes.push(context, const PlacesRatedScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.headset_mic_outlined,
                    title: 'Customer Support',
                    onTap: () => _showSupportSheet(context),
                  ),
                  _MenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    onTap: () =>
                        AppRoutes.push(context, const PrivacyPolicyScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () =>
                        AppRoutes.push(context, const TermsConditionsScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () =>
                        AppRoutes.push(context, const SettingsScreen()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Logout ──
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showLogout(context),
                  icon: Icon(Icons.logout, color: cs.onPrimary, size: 20),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.onSurface,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    String name,
    String email,
    dynamic followerCount,
    dynamic followingCount,
    int picksCount,
  ) {
    final userSession = ref.watch(userSessionServiceProvider);
    final cs = Theme.of(context).colorScheme;
    final String? serverImagePath = userSession.getCurrentUserProfilePicture();
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    String formatCount(dynamic c) {
      final n = c is int ? c : 0;
      if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
      return n.toString();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF75A638).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF75A638),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  backgroundImage: serverImagePath != null
                      ? CachedNetworkImageProvider(
                          ApiEndpoints.resolveServerUrl(serverImagePath),
                        )
                      : null,
                  child: serverImagePath == null
                      ? Text(
                          initial,
                          style: TextStyle(
                            color: const Color(0xFF75A638),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_note,
                  color: Colors.white.withOpacity(0.7),
                  size: 28,
                ),
                onPressed: () {
                  AppRoutes.push(context, const EditProfileScreen());
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(value: picksCount.toString(), label: 'Picks'),
              _Stat(value: formatCount(followerCount), label: 'Followers'),
              _Stat(value: formatCount(followingCount), label: 'Following'),
            ],
          ),
        ],
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email_outlined, color: cs.primary),
              title: const Text('Email Us'),
              subtitle: const Text('support@peerpicks.com'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(Icons.chat_outlined, color: cs.primary),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 9am - 5pm EST'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: cs.primary),
              title: const Text('FAQ & Help Center'),
              subtitle: const Text('Find answers to common questions'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutDialog(
        onConfirm: () async {
          await ref.read(authViewModelProvider.notifier).logout();
        },
      ),
    );
  }
}

// ─── Stat Widget ─────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: const Color(0xFF75A638), fontSize: 13),
        ),
      ],
    );
  }
}

// ─── Menu Item Widget ────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: cs.onSurface, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: cs.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    );
  }
}
