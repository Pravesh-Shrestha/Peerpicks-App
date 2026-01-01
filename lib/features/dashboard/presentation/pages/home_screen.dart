import 'package:flutter/material.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/add_review_screen.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/favorites_screen.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = const [
    DashboardScreen(),
    FavoritesScreen(),
    AddReviewScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  void _onTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Colors.lightGreen;
    const Color inactiveColor = Colors.white;

    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTab(2),
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.black,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom bar with notch
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.black,
        elevation: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavIcon(
                icon: Icons.home,
                index: 0,
                selectedIndex: _selectedIndex,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _onTab(0),
              ),
              _NavIcon(
                icon: Icons.favorite,
                index: 1,
                selectedIndex: _selectedIndex,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _onTab(1),
              ),
              const SizedBox(width: 48), // space for FAB
              _NavIcon(
                icon: Icons.notifications,
                index: 3,
                selectedIndex: _selectedIndex,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _onTab(3),
              ),
              _NavIcon(
                icon: Icons.person,
                index: 4,
                selectedIndex: _selectedIndex,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _onTab(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == selectedIndex;
    return IconButton(
      icon: Icon(icon, color: isActive ? activeColor : inactiveColor, size: 28),
      onPressed: onTap,
    );
  }
}
