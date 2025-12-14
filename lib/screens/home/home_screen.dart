import 'package:flutter/material.dart';
import 'package:peerpicks/screens/home/home_screen/add_review_screen.dart';
import 'package:peerpicks/screens/home/home_screen/dashboard_screen.dart';
import 'package:peerpicks/screens/home/home_screen/favorites_screen.dart';
import 'package:peerpicks/screens/home/home_screen/notification_screen.dart';
import 'package:peerpicks/screens/home/home_screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const DashboardScreen(),
    const FavoritesScreen(),
    const AddReviewScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bottom-Navigation"),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBarTheme(
        data: Theme.of(context).bottomNavigationBarTheme,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
