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

/// Foreground with text, buttons, logos - Responsive
class HomeSectionForeground extends StatelessWidget {
  const HomeSectionForeground({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if mobile view
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SizedBox(
      height: 800,
      width: double.infinity,
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 60, vertical: 150)
            : const EdgeInsets.only(left: 120, right: 80, top: 150),
        child: Column(
          crossAxisAlignment:
              isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            // Headline
            Text(
              "Public Employment\nService Office – Makati",
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: isMobile ? 42 : 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // Subheadline
            Text(
              "Connecting job seekers, employers, and opportunities in Makati City.",
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: isMobile ? 30 : 40),

            // Buttons
            isMobile
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const JobsPage()),
                            );
                          },
                          child: const Text(
                            "Find Jobs",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ServicesPage()),
                            );
                          },
                          child: const Text(
                            "Explore Services",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
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
                            MaterialPageRoute(
                                builder: (_) => const JobsPage()),
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
                            MaterialPageRoute(
                                builder: (_) => const ServicesPage()),
                          );
                        },
                        child: const Text(
                          "Explore Services",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

            SizedBox(height: isMobile ? 40 : 60),

            // Trusted by section
            Padding(
              padding: isMobile
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trusted by:",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: isMobile
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/makati_logo.png',
                            height: isMobile ? 60 : 80,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "MAKATI",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: isMobile ? 16 : 20),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: isMobile ? 60 : 80,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "PESO",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
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