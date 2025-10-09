import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🔹 Import all your admin pages here
import 'package:peso_makati_website_application/admin_page/page3.dart';
import 'package:peso_makati_website_application/admin_page/page4.dart';
import 'package:peso_makati_website_application/admin_page/post_job.dart';
import '../login_page.dart';
import 'announcement_page.dart';
import 'find_jobs.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage>
    with SingleTickerProviderStateMixin {
  int _currentPageIndex = 0;
  bool _showNotificationBox = false;

  // 🔹 Define the admin pages
  final List<Widget> _pages = [
    JobsPageAdmin(),               // Job Posting Page
    Page2Admin(),                  // Placeholder or another page
    Page3Admin(),                  // Job Management Page
    AdminDashboardPageAdmin(),     // Job Analytics Page
    AnnouncementPageAdmin(),       // Announcements Page
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
              'PESO MAKATI - ADMIN DASHBOARD',
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          drawer: isDesktop ? null : Drawer(child: _buildDrawerContent(context)),
          body: isDesktop
              ? Row(
            children: [
              Container(
                width: 250,
                color: Colors.white,
                child: _buildDrawerContent(context),
              ),
              Expanded(child: _pages[_currentPageIndex]),
            ],
          )
              : _pages[_currentPageIndex],
        ),

        // 🔹 Floating Notification Box
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
                    ),
                  ],
                ),
                child: const Text(
                  '🔔 No notifications yet!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

        // 🔹 Floating Notification Button
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

  // 🔹 Drawer Navigation
  Widget _buildDrawerContent(BuildContext context) {
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
        const Divider(),
        _buildSubDrawerItem('Job Posting Page', 0),
        _buildSubDrawerItem('Job Management Page', 2),
        _buildSubDrawerItem('Job Analytics Page', 3),
        _buildSubDrawerItem('Announcements Page', 4),
        const SizedBox(height: 20),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text(
            'Log Out',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginPage(
                    showRegisterPage: () {},
                  ),
                ),
                    (route) => false,
              );
            }
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // 🔹 Drawer Item Builder (Fixed)
  Widget _buildSubDrawerItem(String title, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 60, right: 16),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      selected: _currentPageIndex == index,
      selectedTileColor: Colors.green[100],
      onTap: () {
        setState(() {
          _currentPageIndex = index;
        });

        // ✅ Close only the drawer (not the entire page)
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
      },
    );
  }
}
