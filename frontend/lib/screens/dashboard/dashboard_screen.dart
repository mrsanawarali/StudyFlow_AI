import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/screens/explore/explore_screen.dart';
import 'package:untitled/screens/dashboard/profile_screen.dart';
import '../logout_dialog.dart';
import 'dashboard_home.dart';
import '../../clippers/top_pattern_clipper.dart';
import 'schedule/schedule_screen.dart';
import 'grade_calculator/grade_calculator_screen.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const ScheduleScreen(),
    const ExploreScreen(),
    const GradeCalculatorScreen(),
    const ProfileScreen(),

    // Add other screens later:
    // ScheduleScreen(), ExploreScreen(), etc.
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2660),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Learning One',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 12.0),
        //     child: CircleAvatar(
        //       radius: 18,
        //       backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
        //     ),
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: TopPatternClipper(),
            child: Container(
              height: 120,
              color: const Color(0xFF1B2660),
            ),
          ),
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF1B2660),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Timetable'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) => Drawer(
    backgroundColor: const Color(0xFFFFFFFF),
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Color(0xFF1B2660)),
          child: Text('Menu',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Color(0xFF1B2660)),
          title: Text('Logout', style: GoogleFonts.poppins(color: Color(0xFF1B2660))),
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const LogoutDialog(),
            );
          },
        ),

      ],
    ),
  );
}
