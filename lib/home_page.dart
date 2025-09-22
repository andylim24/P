import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:peso/navigation/application_tracker.dart';
import 'package:peso/navigation/dashboard.dart';
import 'package:peso/navigation/post_job.dart'; // Admin main
import 'package:peso/navigation/find_jobs.dart'; // Find Jobs
import 'package:peso/navigation/profile.dart';
import 'package:peso/navigation/notif.dart';
import 'package:peso/navigation/aboutus.dart';
import 'package:peso/navigation/page3.dart'; // Job Management
import 'package:peso/navigation/page4.dart'; // Job Analytics

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentPageIndex = 0;
  bool _adminExpanded = false;
  bool _showNotificationBox = false;

  final List<Widget> _pages = [
    Page1(),
    Page2(),
    Profile(),
    Page3(),
    AdminDashboardPage(),
    AboutUs(),
    ApplicationTracker(),
    Dashboard(),
    Notif(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue.shade100,
            centerTitle: true,
            title: Text(
              'PESO MAKATI - JOB RECOMMENDATION APP',
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          drawer: isDesktop ? null : Drawer(child: _buildDrawerContent()),
          body: isDesktop
              ? Row(
            children: [
              Container(
                width: 250,
                color: Colors.white,
                child: _buildDrawerContent(),
              ),
              Expanded(child: _pages[_currentPageIndex]),
            ],
          )
              : _pages[_currentPageIndex],
        ),

        // Notification Popup Box
        if (_showNotificationBox)
          Positioned(
            bottom: 90,
            right: 20,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Text(
                  '🔔 No notifications yet!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

        // Floating Notification Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _showNotificationBox = !_showNotificationBox;
              });
            },
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.notifications, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Image(
            image: AssetImage('assets/images/logo.png'),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        ExpansionTile(
          leading: const Icon(Icons.work_outline),
          title: const Text(
            'Admin (Experimental)',
            style: TextStyle(fontSize: 18),
          ),
          initiallyExpanded: _adminExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _adminExpanded = expanded;
            });
          },
          children: [
            _buildSubDrawerItem('Job Posting Page', 0),
            _buildSubDrawerItem('Job Management Page', 3),
            _buildSubDrawerItem('Job Analytics Page', 4),
          ],
        ),
        _buildDrawerItem(Icons.dashboard, 'Dashboard', 7),
        _buildDrawerItem(Icons.info_outline, 'About Us', 5),
        _buildDrawerItem(Icons.search, 'Find Jobs', 1),
        _buildDrawerItem(Icons.person, 'Profile', 2),
        _buildDrawerItem(Icons.track_changes, 'Application Tracker', 6),
        _buildDrawerItem(Icons.notifications, 'Notification', 8),
        const SizedBox(height: 20),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text(
            'Log Out',
            style: TextStyle(fontSize: 18),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      selected: _currentPageIndex == index,
      tileColor: _currentPageIndex == index ? Colors.green[100] : null,
      onTap: () {
        setState(() {
          _currentPageIndex = index;
        });
        Navigator.of(context).maybePop();
      },
    );
  }

  Widget _buildSubDrawerItem(String title, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 60, right: 16),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      selected: _currentPageIndex == index,
      tileColor: _currentPageIndex == index ? Colors.green[100] : null,
      onTap: () {
        setState(() {
          _currentPageIndex = index;
        });
        Navigator.of(context).maybePop();
      },
    );
  }
}
