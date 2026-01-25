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
  String? _location;
  String? _category;
  String? _logoUrl;
  File? _logoFile;

  // ✅ NEW: Program eligibility checkboxes
  bool _isPWD = false;    // Persons with Disability
  bool _isSPES = false;   // Special Program for Employment of Students
  bool _isMIP = false;    // Mainstreaming Integration Program

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

  final List<String> jobCategories = [
    "Select Category",
    "IT & Software",
    "Customer Service",
    "Healthcare",
    "Education",
    "Construction",
    "Manufacturing",
    "Retail & Sales",
    "Food & Hospitality",
    "Transportation & Logistics",
    "Finance & Accounting",
    "Administrative",
    "Engineering",
    "Other"
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
    _category = data['category'] ?? 'Select Category';
    _logoUrl = data['logoUrl'];

    // ✅ Load program eligibility from existing data
    _isPWD = data['isPWD'] ?? false;
    _isSPES = data['isSPES'] ?? false;
    _isMIP = data['isMIP'] ?? false;
  }

  Future<void> _pickLogo() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _logoFile = File(picked.path));
    }
  }

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

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    String? uploadedUrl = _logoUrl;
    if (_logoFile != null) {
      uploadedUrl = await _uploadLogo(_logoFile!);
      if (uploadedUrl == null) return;
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
      'category': _category,
      'logoUrl': uploadedUrl,
      'postedDate': Timestamp.now(),
      // ✅ NEW: Save program eligibility
      'isPWD': _isPWD,
      'isSPES': _isSPES,
      'isMIP': _isMIP,
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
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Logo"),
                    ),
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
                _buildDropdown("Education Level", educationLevels, _educationLevel,
                    (v) => setState(() => _educationLevel = v)),
                const SizedBox(height: 10),
                _buildDropdown("Employment Type", employmentTypes, _employmentType,
                    (v) => setState(() => _employmentType = v)),
                const SizedBox(height: 10),
                _buildDropdown("Job Category", jobCategories, _category,
                    (v) => setState(() => _category = v)),
                const SizedBox(height: 10),
                _buildDropdown("Location (Barangay)", barangays, _location,
                    (v) => setState(() => _location = v)),

                // ✅ NEW: Program Eligibility Section
                const SizedBox(height: 20),
                _buildProgramEligibilitySection(),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _saveJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
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

  // ✅ NEW: Program Eligibility Checkboxes
  Widget _buildProgramEligibilitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.accessibility_new, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Program Eligibility',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Check if this job is applicable for the following programs:',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          _buildCheckboxTile(
            value: _isPWD,
            onChanged: (v) => setState(() => _isPWD = v ?? false),
            title: 'PWD',
            subtitle: 'Persons with Disability',
            icon: Icons.accessible,
          ),
          _buildCheckboxTile(
            value: _isSPES,
            onChanged: (v) => setState(() => _isSPES = v ?? false),
            title: 'SPES',
            subtitle: 'Special Program for Employment of Students',
            icon: Icons.school,
          ),
          _buildCheckboxTile(
            value: _isMIP,
            onChanged: (v) => setState(() => _isMIP = v ?? false),
            title: 'MIP',
            subtitle: 'Makati Internship Program',
            icon: Icons.groups,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required Function(bool?) onChanged,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, size: 20, color: value ? Colors.blue.shade700 : Colors.grey),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: value ? Colors.blue.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: Colors.blue.shade700,
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