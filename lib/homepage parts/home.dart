import 'package:flutter/material.dart';
import '../top navigations/job_listing_page.dart';
import '../top navigations/services_page.dart';

/// Background only (no buttons/text)
class HomeSectionBackground extends StatelessWidget {
  const HomeSectionBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 800,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/homebackground.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.5), // dark overlay
      ),
    );
  }
}

/// Foreground with text, buttons, logos
class HomeSectionForeground extends StatelessWidget {
  const HomeSectionForeground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 800,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 120, right: 80, top: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline
            const Text(
              "Public Employment\nService Office – Makati",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Subheadline
            const Text(
              "Connecting job seekers, employers, and opportunities in Makati City.",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),

            // Buttons
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JobsPage()),
                    );
                  },
                  child: const Text(
                    "Find Jobs",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ServicesPage()),
                    );
                  },
                  child: const Text(
                    "Explore Services",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Trusted by section
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trusted by:",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/makati_logo.png',
                            height: 80,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "MAKATI",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 80,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "PESO",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
