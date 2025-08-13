import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isUploading = false;

  List<Map<String, dynamic>> appliedJobs = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String? _selectedBarangay;

  final List<String> barangays = [
    'Comembo', 'East Rembo', 'Pembo', 'Pitogo', 'Post Proper Northside',
    'Post Proper Southside', 'Rizal', 'South Cembo', 'West Rembo', 'Guadalupe Viejo',
    'Guadalupe Nuevo', 'Cembo', 'Forbes Park', 'San Lorenzo', 'Urdaneta'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAppliedJobs();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
        _nameController.text = userData!['fullName'] ?? '';
        _emailController.text = userData!['email'] ?? '';
        _selectedBarangay = userData!['barangay'] ?? null;
        _skillsController.text = (userData!['skills'] as List<dynamic>?)?.join(', ') ?? '';
      });
    }
  }

  Future<void> _loadAppliedJobs() async {
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final List<dynamic> appliedJobsData = userDoc.data()?['appliedJobs'] ?? [];

    List<Map<String, dynamic>> jobsWithAppliedDate = [];

    for (final entry in appliedJobsData) {
      if (entry is Map<String, dynamic> && entry['jobId'] != null && entry['appliedAt'] != null) {
        final jobId = entry['jobId'] as String;
        final appliedAt = entry['appliedAt'] as Timestamp;

        final jobDoc = await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
        if (jobDoc.exists) {
          final jobData = jobDoc.data()!;
          jobsWithAppliedDate.add({
            'job': jobData,
            'appliedAt': appliedAt,
          });
        }
      }
    }

    jobsWithAppliedDate.sort((a, b) {
      final aDate = (a['appliedAt'] as Timestamp).toDate();
      final bDate = (b['appliedAt'] as Timestamp).toDate();
      return bDate.compareTo(aDate);
    });

    setState(() {
      appliedJobs = jobsWithAppliedDate;
    });
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

  Future<void> _uploadFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.bytes != null && user != null) {
      final fileBytes = result.files.single.bytes!;
      final fileName = '$type/${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      setState(() => isUploading = true);

      try {
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putData(fileBytes);
        final downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          '${type}Url': downloadUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.toUpperCase()} uploaded successfully!')),
        );

        await _loadUserData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  Future<void> _removeFile(String type) async {
    final field = '${type}Url';
    if (userData?[field] != null && user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
          field: FieldValue.delete(),
        });
        setState(() => userData![field] = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.toUpperCase()} removed.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing ${type.toUpperCase()}: $e')),
        );
      }
    }
  }

  void _viewResume(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file link')),
      );
    }
  }

  void _showJobDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.work_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            data['title'] ?? 'Job Details',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: [
                        _buildTableRow(Icons.business, 'Company', data['company']),
                        _buildTableRow(Icons.description, 'Description', data['description']),
                        _buildTableRow(Icons.assignment_turned_in, 'Requirements', data['requirements']),
                        _buildTableRow(Icons.build, 'Skills', (data['requiredSkills'] as List).join(', ')),
                        _buildTableRow(Icons.location_on, 'Location', data['location']),
                        _buildTableRow(
                          Icons.calendar_today,
                          'Posted',
                          (data['postedDate'] as Timestamp).toDate().toLocal().toString().split('.')[0],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _buildTableRow(IconData icon, String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.blueAccent),
              const SizedBox(width: 6),
              Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 14),
            softWrap: true,
          ),
        ),
      ],
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildTextField('Full Name', _nameController),
                          _buildTextField('Email', _emailController),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Barangay',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              value: _selectedBarangay,
                              items: barangays.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                              onChanged: (val) => setState(() => _selectedBarangay = val),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                          ),
                          _buildTextField('Skills (comma separated)', _skillsController),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            onPressed: _saveProfile,
                          ),

                          const Divider(height: 32),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              bool isMobile = constraints.maxWidth < 500;
                              return isMobile
                                  ? Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: _buildUploadBox('Resume', 'resume'),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _buildUploadBox('CV', 'cv'),
                                  ),
                                ],
                              )
                                  : Row(
                                children: [
                                  Expanded(child: _buildUploadBox('Resume', 'resume')),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildUploadBox('CV', 'cv')),
                                ],
                              );
                            },
                          ),


                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Applied Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          if (appliedJobs.isEmpty)
                            const Text('No jobs applied yet.')
                          else
                            ...appliedJobs.map((entry) {
                              final job = entry['job'] as Map<String, dynamic>;
                              final appliedAt = entry['appliedAt'] as Timestamp;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Title: ${job['title'] ?? 'No title'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Company: ${job['company'] ?? 'Unknown'}'),
                                      Text('Location: ${job['location'] ?? 'Unknown'}'),
                                      Text('Applied Date: ${appliedAt.toDate().toLocal().toString().split('.')[0]}'),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.info_outline),
                                          label: const Text('View Details'),
                                          onPressed: () => _showJobDetailsDialog(context, job),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox(String label, String type) {
    final field = '${type}Url';
    final bgColor = type == 'resume' ? Colors.blue.shade700 : Colors.green.shade700;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          if (userData != null && userData![field] != null)
            ListTile(
              tileColor: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.picture_as_pdf, color: Colors.white),
              title: Text(
                'View $label',
                style: const TextStyle(decoration: TextDecoration.underline, color: Colors.white),
              ),
              onTap: () => _viewResume(userData![field]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => _removeFile(type),
              ),
            ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: bgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: isUploading ? null : () => _uploadFile(type),
            icon: isUploading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.upload_file),
            label: Text(
              isUploading
                  ? 'Uploading...'
                  : (userData?[field] != null ? 'Update $label (PDF)' : 'Upload $label (PDF)'),
            ),
          ),
        ],
      ),
    );
  }

}
