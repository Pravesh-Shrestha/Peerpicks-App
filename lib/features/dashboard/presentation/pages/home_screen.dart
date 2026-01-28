import 'package:flutter/material.dart';
import 'package:peerpicks/features/reviews/presentation/pages/add_review_screen.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/favorites_screen.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/notification_screen.dart';
import 'package:peerpicks/features/profile/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  final List<Widget> lstBottomScreen = const [
    DashboardScreen(),
    FavoritesScreen(),
    AddReviewScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTab(int index) {
    setState(() => _selectedIndex = index);
    if (index == 2) {
      _fabController.forward().then((_) => _fabController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      extendBody: true,
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.85).animate(
          CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 122, 187, 102), Color(0xFFB4D333)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _onTab(2),
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            elevation: 0,
            child: const Icon(Icons.add_rounded, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          color: const Color.fromARGB(255, 0, 0, 0),
          elevation: 0,
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ModernNavIcon(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  selectedIndex: _selectedIndex,
                  onTap: () => _onTab(0),
                ),
                _ModernNavIcon(
                  icon: Icons.favorite_rounded,
                  label: 'Favorites',
                  index: 1,
                  selectedIndex: _selectedIndex,
                  onTap: () => _onTab(1),
                ),
                const SizedBox(width: 60),
                _ModernNavIcon(
                  icon: Icons.notifications_rounded,
                  label: 'Alerts',
                  index: 3,
                  selectedIndex: _selectedIndex,
                  onTap: () => _onTab(3),
                ),
                _ModernNavIcon(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                  selectedIndex: _selectedIndex,
                  onTap: () => _onTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernNavIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _ModernNavIcon({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<_ModernNavIcon> createState() => _ModernNavIconState();
}

class _ModernNavIconState extends State<_ModernNavIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ModernNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == widget.selectedIndex) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.index == widget.selectedIndex;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color.fromARGB(
                                255,
                                143,
                                227,
                                7,
                              ).withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: isActive
                            ? const Color(0xFFB4D333)
                            : Colors.white.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isActive ? 10 : 9,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF66BB6A)
                    : Colors.white.withOpacity(0.5),
                letterSpacing: 0.3,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}
