import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class JobFormDialog extends StatefulWidget {
  final DocumentSnapshot? doc;
  const JobFormDialog({Key? key, this.doc}) : super(key: key);

  @override
  State<JobFormDialog> createState() => _JobFormDialogState();
}

class _JobFormDialogState extends State<JobFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _title;
  late TextEditingController _company;
  late TextEditingController _description;
  late TextEditingController _requirements;
  late TextEditingController _skills;
  late TextEditingController _salaryMin;
  late TextEditingController _salaryMax;

  String? _educationLevel;
  String? _employmentType;
  String? _location; // Barangay
  String? _logoUrl;
  File? _logoFile;

  final picker = ImagePicker();

  final List<String> barangays = [
    'Barangays', 'Poblacion', 'Bel-Air', 'San Antonio', 'Guadalupe Nuevo',
    'Cembo', 'West Rembo', 'Tejeros', 'Rizal',
  ];

  final List<String> educationLevels = [
    "High School", "College Graduate", "Master's", "Doctorate"
  ];

  final List<String> employmentTypes = [
    "Contractual", "Permanent", "Project-based", "Work from home"
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.doc?.data() as Map<String, dynamic>? ?? {};
    _title = TextEditingController(text: data['title'] ?? '');
    _company = TextEditingController(text: data['company'] ?? '');
    _description = TextEditingController(text: data['description'] ?? '');
    _requirements = TextEditingController(text: data['requirements'] ?? '');
    _skills = TextEditingController(
        text: (data['requiredSkills'] as List<dynamic>?)?.join(', ') ?? '');
    _salaryMin = TextEditingController(text: data['salaryMin']?.toString() ?? '');
    _salaryMax = TextEditingController(text: data['salaryMax']?.toString() ?? '');
    _educationLevel = data['educationLevel'];
    _employmentType = data['employmentType'];
    _location = data['location'] ?? 'Barangays';
    _logoUrl = data['logoUrl'];
  }

  /// Pick image from gallery
  Future<void> _pickLogo() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _logoFile = File(picked.path));
    }
  }

  /// Upload logo to Firebase Storage
  Future<String?> _uploadLogo(File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('job_logos/${DateTime.now().millisecondsSinceEpoch}.png');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logo upload failed: $e')));
      return null;
    }
  }

  /// Save or update job
  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    String? uploadedUrl = _logoUrl;
    if (_logoFile != null) {
      uploadedUrl = await _uploadLogo(_logoFile!);
      if (uploadedUrl == null) return; // stop if upload failed
    }

    final jobData = {
      'title': _title.text.trim(),
      'company': _company.text.trim(),
      'description': _description.text.trim(),
      'requirements': _requirements.text.trim(),
      'requiredSkills': _skills.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'salaryMin': double.tryParse(_salaryMin.text) ?? 0,
      'salaryMax': double.tryParse(_salaryMax.text) ?? 0,
      'educationLevel': _educationLevel,
      'employmentType': _employmentType,
      'location': _location,
      'logoUrl': uploadedUrl,
      'postedDate': Timestamp.now(),
    };

    try {
      if (widget.doc == null) {
        await FirebaseFirestore.instance.collection('jobs').add(jobData);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Job posted successfully!')));
      } else {
        await widget.doc!.reference.update(jobData);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Job updated successfully!')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 200, vertical: 50),
      child: Container(
        width: isWide ? 600 : double.infinity,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doc == null ? 'Add Job Posting' : 'Edit Job Posting',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Logo picker
                Row(
                  children: [
                    _logoFile != null
                        ? CircleAvatar(backgroundImage: FileImage(_logoFile!), radius: 30)
                        : _logoUrl != null
                        ? CircleAvatar(backgroundImage: NetworkImage(_logoUrl!), radius: 30)
                        : const CircleAvatar(radius: 30, child: Icon(Icons.business)),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                        onPressed: _pickLogo, icon: const Icon(Icons.upload), label: const Text("Upload Logo")),
                  ],
                ),
                const SizedBox(height: 20),

                _buildTextField(_company, "Company Name"),
                _buildTextField(_title, "Job Title"),
                _buildTextField(_description, "Job Description", maxLines: 3),
                _buildTextField(_requirements, "Requirements", maxLines: 2),
                _buildTextField(_skills, "Required Skills (comma separated)"),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_salaryMin, "Min Salary")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(_salaryMax, "Max Salary")),
                  ],
                ),

                const SizedBox(height: 10),
                _buildDropdown("Education Level", educationLevels, _educationLevel, (v) => setState(() => _educationLevel = v)),
                const SizedBox(height: 10),
                _buildDropdown("Employment Type", employmentTypes, _employmentType, (v) => setState(() => _employmentType = v)),
                const SizedBox(height: 10),
                _buildDropdown("Location (Barangay)", barangays, _location, (v) => setState(() => _location = v)),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _saveJob,
                    child: Text(widget.doc == null ? "Post Job" : "Update Job"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required field' : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null || v == items[0] ? 'Select a valid option' : null,
    );
  }
}
