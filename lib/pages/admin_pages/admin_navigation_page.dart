import 'package:attendance_system/pages/admin_pages/admin_attendance.dart';
import 'package:attendance_system/pages/admin_pages/admin_employee.dart';
import 'package:attendance_system/pages/admin_pages/admin_meetings.dart';
import 'package:attendance_system/pages/admin_pages/admin_settings.dart';
import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class AdminNavigationPage extends StatefulWidget {
  const AdminNavigationPage({super.key});

  @override
  State<AdminNavigationPage> createState() => _AdminNavigationPageState();
}

class _AdminNavigationPageState extends State<AdminNavigationPage> {
  int _selectedIndex = 0;

  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  final List<Widget> _pages = [
     AdminDashboard(),
     AdminAttendance(),
     AdminEmployees(),
     AdminMeetingsPage(),
     AdminSettingsPage(),
  ];

  // List of page titles
  final List<String> _pageTitles = [
    'Dashboard',
    'Attendance',
    'Employees',
    'Meetings',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: darkBlue,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: darkBlue,
          selectedItemColor: accentBlue,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.check_circle_outlined),
              activeIcon: const Icon(Icons.check_circle),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_outline),
              activeIcon: const Icon(Icons.people),
              label: 'Employees',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              activeIcon: const Icon(Icons.calendar_month),
              label: 'Meetings',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
