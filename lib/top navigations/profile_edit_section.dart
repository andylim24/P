// import necessary packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditSection extends StatefulWidget {
  const ProfileEditSection({super.key});

  @override
  State<ProfileEditSection> createState() => _ProfileEditSectionState();
}

class _ProfileEditSectionState extends State<ProfileEditSection> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _skillsController = TextEditingController();

  String? _selectedBarangay;
  Map<String, dynamic>? userData;

final List<String> barangays = [
  'Cembo', 'Comembo', 'East Rembo', 'Forbes Park', 'Guadalupe Nuevo',
  'Guadalupe Viejo', 'Pembo', 'Pitogo', 'Poblacion', // <-- Add this
  'Post Proper Northside', 'Post Proper Southside', 'Rizal', 
  'San Lorenzo', 'South Cembo', 'Urdaneta', 'West Rembo',
];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
        _nameController.text = userData?['fullName'] ?? '';
        _emailController.text = userData?['email'] ?? '';
        _selectedBarangay = userData?['barangay'];
        _skillsController.text = (userData?['skills'] as List?)?.join(', ') ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'barangay': _selectedBarangay,
        'skills': _skillsController.text.split(',').map((s) => s.trim()).toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      await _loadUserData();
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField('Full Name', _nameController),
              _buildTextField('Email', _emailController),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Barangay',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedBarangay,
                items: barangays.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => setState(() => _selectedBarangay = val),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField('Skills (comma separated)', _skillsController),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
