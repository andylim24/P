import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peso_makati_website_application/jobseeker_update_page.dart';
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

// ✅ Global cache for username
String? cachedUserName;

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  String? _displayName;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    if (user == null) return;

    if (cachedUserName != null) {
      setState(() => _displayName = cachedUserName);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['fullName'] != null) {
        cachedUserName = data['fullName'];
        setState(() => _displayName = cachedUserName);
      }
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // ✅ NEW: Push page on top (user can go back)
  void _pushPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    // ✅ Responsive padding - smaller on smaller screens
    final horizontalPadding = screenWidth > 1200 ? 100.0 : (screenWidth > 800 ? 40.0 : 16.0);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[900],
        title: Row(
          children: [
            // Left logo
            Padding(
              padding: EdgeInsets.only(left: horizontalPadding),
              child: GestureDetector(
                onTap: () => _navigateTo(context, const HomePage()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isMobile ? "Makati" : "Makati", // ✅ Hide text on mobile
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 8),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
            const Spacer(),


            // Center nav links - only show on larger screens
            if (screenWidth > 1000)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _navButton(context, "Home", const HomePage()),
                  
                  _navButton(context, "Jobs", const JobsPage()),
                  _navButton(context, "Announcements", const ServicesPage()),
                  _navButton(context, "About", const AboutUsPage()),
                  _navButton(context, "Contacts", const ContactsPage()),
                ],
              ),

            const Spacer(),
            const Spacer(),

            // Right actions
            Padding(
              padding: EdgeInsets.only(right: horizontalPadding),
              child: (isMobile || screenWidth <= 1000)
                  ? _mobileMenuButton(context)
                  : _userActions(context),
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
                        Image.asset('assets/images/logo.png',
                            width: 36, height: 36),
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
                  _drawerItem(context, "About Us", const AboutUsPage()),
                  _drawerItem(context, "Contacts", const ContactsPage()),
                  const Divider(),
                  _drawerUserActions(context),
                ],
              ),
            )
          : null,
      body: widget.child,
    );
  }

  Widget _navButton(BuildContext context, String text, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => _navigateTo(context, page),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
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

  Widget _userActions(BuildContext context) {
    if (user == null) {
      // Not logged in - ✅ PUSH AuthPage on top (user can go back)
      return Row(
        children: [
          ActionChip(
            label: const Text("Sign Up"),
            onPressed: () {
              _pushPage(context, const AuthPage(showLogin: false));
            },
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: const Text("Log In"),
            onPressed: () {
              _pushPage(context, const AuthPage(showLogin: true));
            },
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.blue),
          ),
        ],
      );
    } else {
      // Logged in
      final displayText =
          _displayName ?? cachedUserName ?? user!.email ?? "User";

      return Row(
        children: [
          Text(
            displayText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                cachedUserName = null;
                await FirebaseAuth.instance.signOut();
                if (context.mounted) _navigateTo(context, const HomePage());
              } else if (value == 'profile') {
                _pushPage(context, const ProfilePage());
              } else if (value == 'application') {
                _pushPage(context, const ApplicationTracker());
              } else if (value == 'notification') {
                _pushPage(context, const Notif());
              } else if (value == 'jobseeker') {
                _pushPage(context, const JobseekerUpdatePage());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text("Profile Page")),
              PopupMenuItem(
                  value: 'application', child: Text("Application Tracker")),
              PopupMenuItem(value: 'notification', child: Text("Notifications")),
              PopupMenuItem(
                  value: 'jobseeker', child: Text("Edit Jobseeker Profile")),
              PopupMenuItem(value: 'logout', child: Text("Log Out")),
            ],
          ),
        ],
      );
    }
  }

  Widget _drawerItem(BuildContext context, String text, Widget page) {
    return ListTile(
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        _navigateTo(context, page);
      },
    );
  }

  Widget _drawerUserActions(BuildContext context) {
    if (user == null) {
      // Not logged in - ✅ PUSH AuthPage on top (user can go back)
      return Column(
        children: [
          ListTile(
            title: const Text("Sign Up"),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              _pushPage(context, const AuthPage(showLogin: false));
            },
          ),
          ListTile(
            title: const Text("Log In"),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              _pushPage(context, const AuthPage(showLogin: true));
            },
          ),
        ],
      );
    } else {
      final displayText =
          _displayName ?? cachedUserName ?? user!.email ?? "User";

      return Column(
        children: [
          ListTile(title: Text(displayText)),
          ListTile(
            title: const Text("Profile Page"),
            onTap: () {
              Navigator.pop(context);
              _pushPage(context, const ProfilePage());
            },
          ),
          ListTile(
            title: const Text("Log Out"),
            onTap: () async {
              Navigator.pop(context);
              cachedUserName = null;
              await FirebaseAuth.instance.signOut();
              _navigateTo(context, const HomePage());
            },
          ),
        ],
      );
    }
  }
}

// ✅ Helper class for instant page transitions (for navigation links)
class MaterialPageBuilder extends PageRouteBuilder {
  MaterialPageBuilder({Widget? page, bool showLogin = false})
      : super(
          pageBuilder: (_, __, ___) =>
              page ?? AuthPage(showLogin: showLogin),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
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
          const HomeSectionBackground(),
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