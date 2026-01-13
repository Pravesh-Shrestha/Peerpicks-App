import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/widgets/logout_dialog.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => LogoutDialog(
        onConfirm: () async {
          await ref.read(authViewModelProvider.notifier).logout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // 1. Optional: Adds a header bar
      appBar: AppBar(title: const Text("Profile")),

      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centers items vertically
          children: [
            const Text("I am profile screen"),
            const SizedBox(height: 20), // Adds a 20px gap
            // 2. The Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context, ref),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
