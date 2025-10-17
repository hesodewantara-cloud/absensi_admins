import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/attendance');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/rooms');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/users');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/leaves');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(FontAwesomeIcons.chartPie),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(FontAwesomeIcons.solidCalendarCheck),
                label: Text('Absensi'),
              ),
              NavigationRailDestination(
                icon: Icon(FontAwesomeIcons.doorOpen),
                label: Text('Ruangan'),
              ),
              NavigationRailDestination(
                icon: Icon(FontAwesomeIcons.users),
                label: Text('Pengguna'),
              ),
              NavigationRailDestination(
                icon: Icon(FontAwesomeIcons.solidFileLines),
                label: Text('Izin'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}