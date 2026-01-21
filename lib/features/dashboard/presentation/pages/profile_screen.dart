import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/app/routes/app_routes.dart';
import 'package:peerpicks/core/widgets/logout_dialog.dart';
import 'package:peerpicks/features/auth/presentation/state/auth_state.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/edit_profile_screen.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_in_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const Color peerLime = Color(0xFFB4D333); // PeerPicks Brand Color

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen for auth state changes to navigate on logout
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        AppRoutes.navigateToSignInAfterLogout(context, const SignInScreen());
      }
    });

    // 2. Access session data
    final userSession = ref.watch(userSessionServiceProvider);
    final userName = userSession.getCurrentUserFullName() ?? 'Guest User';
    final userEmail = userSession.getCurrentUserEmail() ?? 'guest@example.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: peerLime,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      // Use SingleChildScrollView to prevent UI overlap on tablet/landscape
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- TOP SECTION: LIME HEADER + FLOATING BLACK CARD ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(height: 60, width: double.infinity, color: peerLime),
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  child: _buildProfileCard(context, userName, userEmail),
                ),
              ],
            ),

            // Spacer to account for the overlapping height of the card
            const SizedBox(height: 150),

            // --- MIDDLE SECTION: MENU ITEMS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.business_center_outlined,
                    title: 'List of places rated',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: 'Customer Support',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy and Policy',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms and Conditions',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Setting',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),

            // --- BOTTOM SECTION: LOGOUT BUTTON ---
            // Added bottom padding to ensure it's not cut off by floating nav bars
            Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showLogout(context, ref),
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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

  // --- WIDGET BUILDERS ---

  Widget _buildProfileCard(BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_note,
                  color: Colors.white70,
                  size: 28,
                ),
                onPressed: () {
                  AppRoutes.push(context, const EditProfileScreen());
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(value: "0", label: "Followers"),
              _Stat(value: "0", label: "Following"),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogout(BuildContext context, WidgetRef ref) {
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.black, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    );
  }
}
