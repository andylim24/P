import 'package:flutter/material.dart';

import '../main_homepage.dart';
import '../homepage parts/footer.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/homebackground.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Banner
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue[900]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Contact Us\n\nGet in touch with our team for inquiries, support, or feedback.",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Contacts + Map Container
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 800;

                        return isMobile
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _contactInfo(),
                            const SizedBox(height: 16),
                            _contactImageMap(),
                          ],
                        )
                            : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _contactInfo()),
                            const SizedBox(width: 20),
                            Expanded(child: _contactImageMap()),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Footer
                const FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Our Contacts:",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          "Email: support@example.com\nPhone: +63 912 345 6789\nAddress: 123 Makati City, Philippines",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        SizedBox(height: 20),
        Text(
          "You can also reach out via our social media channels:",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.facebook, color: Colors.blue),
            SizedBox(width: 8),
            Text("Facebook: @OurCompany"),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.circle, color: Colors.lightBlue),
            SizedBox(width: 8),
            Text("Twitter: @OurCompany"),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.circle, color: Colors.purple),
            SizedBox(width: 8),
            Text("Instagram: @OurCompany"),
          ],
        ),
      ],
    );
  }

  // 🔹 Replaced FlutterMap with Static Image
  Widget _contactImageMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/peso_map.jpg',
        fit: BoxFit.cover,
        height: 300,
        width: double.infinity,
      ),
    );
  }
}
