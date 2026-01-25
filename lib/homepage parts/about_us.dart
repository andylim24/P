import 'package:flutter/material.dart';

class AboutUsSection extends StatelessWidget {
  const AboutUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if mobile view
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      height: isMobile ? null : 800,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 🔹 Decorative abstract shapes
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 180,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 🔹 Main Content
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 1000,
              ),
              child: Padding(
                padding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 24, vertical: 60)
                    : const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isMobile
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    // Website title
                    Text(
                      "Public Employment Service Office – Makati",
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        fontSize: isMobile ? 26 : 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main description
                    Text(
                      "Welcome to the official online portal of the Public Employment Service Office – Makati (PESO Makati). "
                      "Our website is your gateway to employment opportunities, career resources, and community support. "
                      "We aim to connect job seekers with reputable employers and provide guidance to achieve sustainable careers.",
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Features - Column for mobile, Row for desktop
                    isMobile
                        ? Column(
                            children: [
                              _buildFeatureCard(
                                icon: Icons.work,
                                title: "Job Listings",
                                description:
                                    "Browse thousands of local employment opportunities across multiple industries.",
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureCard(
                                icon: Icons.event,
                                title: "Job Fairs & Events",
                                description:
                                    "Join exclusive job fairs, workshops, and networking events hosted by PESO Makati.",
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureCard(
                                icon: Icons.school,
                                title: "Career Guidance",
                                description:
                                    "Get career tips, resume assistance, and access to workshops for skill development.",
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureCard(
                                icon: Icons.people,
                                title: "Community Support",
                                description:
                                    "Access support programs and resources for job seekers, students, and local residents.",
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Job Listings
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.work,
                                  title: "Job Listings",
                                  description:
                                      "Browse thousands of local employment opportunities across multiple industries.",
                                ),
                              ),

                              // Job Fairs & Events
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.event,
                                  title: "Job Fairs & Events",
                                  description:
                                      "Join exclusive job fairs, workshops, and networking events hosted by PESO Makati.",
                                ),
                              ),

                              // Career Guidance
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.school,
                                  title: "Career Guidance",
                                  description:
                                      "Get career tips, resume assistance, and access to workshops for skill development.",
                                ),
                              ),

                              // Community Support
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.people,
                                  title: "Community Support",
                                  description:
                                      "Access support programs and resources for job seekers, students, and local residents.",
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 45, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}