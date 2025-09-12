import 'package:flutter/material.dart';
import 'profile_edit_section.dart';
import 'file_upload_section.dart';
import 'applied_jobs_section.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.red),
        elevation: 0,
      ),      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: const [
                ProfileEditSection(),
                SizedBox(height: 24),
                FileUploadSection(),
                SizedBox(height: 24),
                AppliedJobsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
