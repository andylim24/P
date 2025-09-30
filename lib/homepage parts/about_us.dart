import 'package:flutter/material.dart';

class AboutUsSection extends StatelessWidget {
  const AboutUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 800,
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
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Website title
                  const Text(
                    "Public Employment Service Office – Makati",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main description
                  const Text(
                    "Welcome to the official online portal of the Public Employment Service Office – Makati (PESO Makati). "
                        "Our website is your gateway to employment opportunities, career resources, and community support. "
                        "We aim to connect job seekers with reputable employers and provide guidance to achieve sustainable careers.",
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Features row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Job Listings
                      Expanded(
                        child: Container(
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
                            children: const [
                              Icon(Icons.work, size: 45, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                "Job Listings",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Browse thousands of local employment opportunities across multiple industries.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Job Fairs & Events
                      Expanded(
                        child: Container(
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
                            children: const [
                              Icon(Icons.event, size: 45, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                "Job Fairs & Events",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Join exclusive job fairs, workshops, and networking events hosted by PESO Makati.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Career Guidance
                      Expanded(
                        child: Container(
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
                            children: const [
                              Icon(Icons.school, size: 45, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                "Career Guidance",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Get career tips, resume assistance, and access to workshops for skill development.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Community Support
                      Expanded(
                        child: Container(
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
                            children: const [
                              Icon(Icons.people, size: 45, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                "Community Support",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Access support programs and resources for job seekers, students, and local residents.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
