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
import 'jobseeker_registration_page.dart';
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

    // ✅ Use cache if available (prevents flicker)
    if (cachedUserName != null) {
      setState(() => _displayName = cachedUserName);
      return;
    }

    // Otherwise, fetch from Firestore once
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
        transitionDuration: Duration.zero, // no animation
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[900],
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left logo
            Padding(
              padding: const EdgeInsets.only(left: 100),
              child: GestureDetector(
                onTap: () => _navigateTo(context, const HomePage()),
                child: Row(
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

            const Spacer(),

            // Center nav links
            if (!isMobile)
              Row(
                children: [
                  _navButton(context, "Home", const HomePage()),
                  _navButton(context, "Job Listings", const JobsPage()),
                  _navButton(context, "Announcements", const ServicesPage()),
                  _navButton(context, "About Us", const AboutUsPage()),
                  _navButton(context, "Contacts", const ContactsPage()),
                ],
              ),

            const Spacer(),

            // Right actions
            Padding(
              padding: const EdgeInsets.only(right: 100),
              child: isMobile
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
    return TextButton(
      onPressed: () => _navigateTo(context, page),
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

  Widget _userActions(BuildContext context) {
    if (user == null) {
      // Not logged in
      return Row(
        children: [
          ActionChip(
            label: const Text("Sign Up"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageBuilder(showLogin: false));
            },
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: const Text("Log In"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageBuilder(showLogin: true));
            },
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.blue),
          ),
        ],
      );
    } else {
      // Logged in
      final displayText = _displayName ?? cachedUserName ?? user!.email ?? "User";

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
                Navigator.push(context, MaterialPageBuilder(page: const ProfilePage()));
              } else if (value == 'application') {
                Navigator.push(context, MaterialPageBuilder(page: const ApplicationTracker()));
              } else if (value == 'notification') {
                Navigator.push(context, MaterialPageBuilder(page: const Notif()));
              } else if (value == 'jobseeker') {
                Navigator.push(
                  context,
                  MaterialPageBuilder(
                    page: const JobseekerRegistrationPage(isEditMode: true),
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text("Profile Page")),
              PopupMenuItem(value: 'application', child: Text("Application Tracker")),
              PopupMenuItem(value: 'notification', child: Text("Notifications")),
              PopupMenuItem(value: 'jobseeker', child: Text("Jobseeker Registration")),
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
      return Column(
        children: [
          ListTile(
            title: const Text("Sign Up"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageBuilder(showLogin: false));
            },
          ),
          ListTile(
            title: const Text("Log In"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageBuilder(showLogin: true));
            },
          ),
        ],
      );
    } else {
      final displayText = _displayName ?? cachedUserName ?? user!.email ?? "User";

      return Column(
        children: [
          ListTile(title: Text(displayText)),
          ListTile(
            title: const Text("Profile Page"),
            onTap: () => _navigateTo(context, const ProfilePage()),
          ),
          ListTile(
            title: const Text("Log Out"),
            onTap: () async {
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

// ✅ Helper class for instant page transitions
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
