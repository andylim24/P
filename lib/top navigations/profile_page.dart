import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main_homepage.dart';
import 'profile_edit_section.dart';
import 'file_upload_section.dart';
import 'applied_jobs_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Stack(
        children: [
          // Background image with dark overlay
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/homebackground.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const ProfileEditSection(),
                    const SizedBox(height: 24),
                    const FileUploadSection(),
                    const SizedBox(height: 24),
                    const AppliedJobsSection(),
                    const SizedBox(height: 24),

                    // Optional: show user info from Firestore
                    if (user != null)
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(user!.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final data = snapshot.data!.data() as Map<String, dynamic>?;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Full Name: ${data?['fullName'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Email: ${user!.email ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Phone: ${data?['phone'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
