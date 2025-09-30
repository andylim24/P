import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Add font_awesome_flutter to pubspec.yaml

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blueGrey.shade900,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Top part: Links + Social Media
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // About / Logo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "PESO Makati",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "Public Employment Service Office – Makati is your gateway to local employment opportunities, job fairs, and career guidance.",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),

                  // Quick Links
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Quick Links",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text("Home", style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                      Text("About Us", style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                      Text("Announcements", style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                      Text("Job Fairs", style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                      Text("Contact", style: TextStyle(color: Colors.white70)),
                    ],
                  ),

                  // Contact Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Contact Us",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text("📍 123 Makati St., Makati City",
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                      Text("📞 +63 2 1234 5678",
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                      Text("✉ info@pesomakati.gov.ph",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),

                  // Social Media
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Follow Us",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          FaIcon(FontAwesomeIcons.facebook,
                              color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          FaIcon(FontAwesomeIcons.twitter,
                              color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          FaIcon(FontAwesomeIcons.instagram,
                              color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          FaIcon(FontAwesomeIcons.linkedin,
                              color: Colors.white, size: 20),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 🔹 Bottom copyright
              const Center(
                child: Text(
                  "© 2025 Public Employment Service Office – Makati | All Rights Reserved",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
