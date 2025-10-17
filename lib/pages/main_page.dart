import 'package:absensi_admin/pages/dashboard_page.dart';
import 'package:absensi_admin/pages/login_page.dart';
import 'package:absensi_admin/pages/profile_page.dart';
import 'package:absensi_admin/pages/reports_page.dart';
import 'package:absensi_admin/pages/rooms_page.dart';
import 'package:absensi_admin/pages/users_page.dart';
import 'package:absensi_admin/services/auth_service.dart';
import 'package:absensi_admin/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final LocationService _locationService = LocationService();

  final _pages = [
    const DashboardPage(),
    const UsersPage(),
    const RoomsPage(),
    const ReportsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkMockLocation();
  }

  Future<void> _checkMockLocation() async {
    final isMock = await _locationService.isMockLocation();

    if (!mounted) return; // ✅ pastikan widget masih ada sebelum pakai context

    if (isMock) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mock Location Detected'),
          content: const Text(
              'Please disable mock locations to use this application.'),
          actions: [
            TextButton(
              onPressed: () async {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                await authService.signOut();

                if (!context.mounted) return; // ✅ cek mounted lagi sebelum Navigator

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const FaIcon(FontAwesomeIcons.chartPie),
            title: const Text("Dashboard"),
            selectedColor: Colors.indigo,
          ),
          SalomonBottomBarItem(
            icon: const FaIcon(FontAwesomeIcons.users),
            title: const Text("Users"),
            selectedColor: Colors.indigo,
          ),
          SalomonBottomBarItem(
            icon: const FaIcon(FontAwesomeIcons.doorOpen),
            title: const Text("Rooms"),
            selectedColor: Colors.indigo,
          ),
          SalomonBottomBarItem(
            icon: const FaIcon(FontAwesomeIcons.fileLines),
            title: const Text("Reports"),
            selectedColor: Colors.indigo,
          ),
          SalomonBottomBarItem(
            icon: const FaIcon(FontAwesomeIcons.userGear),
            title: const Text("Profile"),
            selectedColor: Colors.indigo,
          ),
        ],
      ),
    );
  }
}
