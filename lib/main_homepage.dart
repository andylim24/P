import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peso_makati_website_application/top%20navigations/about_us_page.dart';
import 'package:peso_makati_website_application/top%20navigations/contacts_page.dart';
import 'package:peso_makati_website_application/top%20navigations/job_listing_page.dart';
import 'package:peso_makati_website_application/top%20navigations/profile_page.dart';
import 'package:peso_makati_website_application/top%20navigations/services_page.dart';

import 'application_tracker.dart';
import 'auth/auth_page.dart';
import 'homepage parts/about_us.dart';
import 'homepage parts/announcements.dart';
import 'homepage parts/footer.dart';
import 'homepage parts/home.dart';
import 'notif.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[900],
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // vertical center
          children: [
            // Left: Logo with 100px padding
            Padding(
              padding: const EdgeInsets.only(left: 100),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Makati",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(), // push center section to the middle

            // Center: Navigation buttons
            if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _navButton(context, "Home", const HomePage()),
                  _navButton(context, "Job Listings", const JobsPage()),
                  _navButton(context, "Announcements", const ServicesPage()),
                  _navButton(context, "About Us", const AboutUsPage()),
                  _navButton(context, "Contacts", const ContactsPage()),
                ],
              ),

            const Spacer(), // push right section to the end

            // Right: User actions with 100px padding
            Padding(
              padding: const EdgeInsets.only(right: 100),
              child: isMobile ? _mobileMenuButton(context) : _userActions(context, user),
            ),
          ],
        ),

      ),
      drawer: isMobile
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[900]),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 36, height: 36),
                  const SizedBox(width: 8),
                  const Text(
                    "Makati",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
            _drawerItem(context, "Home", const HomePage()),
            _drawerItem(context, "Job Listings", const JobsPage()),
            _drawerItem(context, "Announcements", const ServicesPage()),
            _navButton(context, "About Us", const AboutUsPage()),
            _navButton(context, "Contacts", const ContactsPage()),
            const Divider(),
            _drawerUserActions(context, user),
          ],
        ),
      )
          : null,
      body: child,
    );
  }

  Widget _navButton(BuildContext context, String text, Widget? page) {
    return TextButton(
      onPressed: page != null
          ? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      )
          : null,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _mobileMenuButton(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }

  Widget _userActions(BuildContext context, User? user) {
    if (user == null) {
      return Row(
        children: [
          ActionChip(
            label: const Text("Sign Up"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthPage(showLogin: false)),
              );
            },
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: const Text("Log In"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthPage(showLogin: true)),
              );
            },
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.blue),
          ),
        ],
      );
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
        builder: (context, snapshot) {
          String displayName = user.email ?? "User";
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) displayName = data['fullName'] ?? displayName;
          }
          return Row(
            children: [
              Text(
                displayName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                          (route) => false,
                    );
                  } else if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  } else if (value == 'application') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ApplicationTracker()),
                    );
                  } else if (value == 'notification') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Notif()),
                    );
                  }


                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'profile', child: Text("Profile Page")),
                  PopupMenuItem(value: 'logout', child: Text("Log Out")),
                  PopupMenuItem(value: 'application', child: Text("Application Tracker")),
                  PopupMenuItem(value: 'notification', child: Text("Notifications")),
                ],
              ),
            ],
          );
        },
      );
    }
  }


  Widget _drawerItem(BuildContext context, String text, Widget? page) {
    return ListTile(
      title: Text(text),
      onTap: page != null
          ? () {
        Navigator.pop(context); // close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      }
          : null,
    );
  }

  Widget _drawerUserActions(BuildContext context, User? user) {
    if (user == null) {
      return Column(
        children: [
          ListTile(
            title: const Text("Sign Up"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthPage(showLogin: false)),
              );
            },
          ),
          ListTile(
            title: const Text("Log In"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthPage(showLogin: true)),
              );
            },
          ),
        ],
      );
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
        builder: (context, snapshot) {
          String displayName = user.email ?? "User";
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) displayName = data['fullName'] ?? displayName;
          }
          return Column(
            children: [
              ListTile(title: Text(displayName)),
              ListTile(title: const Text("Profile Page")),
              ListTile(title: const Text("Log Out")),
            ],
          );
        },
      );
    }
  }
}

// ------------------------
// HomePage
// ------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Stack(
        children: [
          // fixed background
          const HomeSectionBackground(),

          // scrollable sections
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: const [
                HomeSectionForeground(),
                AnnouncementsSection(),
                AboutUsSection(),
                FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
