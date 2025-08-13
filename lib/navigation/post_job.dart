import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBarangay;

  final List<String> barangays = [
    'Barangays',
    'Poblacion',
    'Bel-Air',
    'San Antonio',
    'Guadalupe Nuevo',
    'Cembo',
    'West Rembo',
    'Tejeros',
    'Rizal',
  ];

  void _openBarangayDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Barangay'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: barangays.map((b) {
              return ListTile(
                title: Text(b),
                onTap: () {
                  setState(() => _selectedBarangay = b);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _openJobForm({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _companyController.text = data['company'];
      _titleController.text = data['title'];
      _descriptionController.text = data['description'];
      _requirementsController.text = data['requirements'];
      _skillsController.text = (data['requiredSkills'] as List<dynamic>).join(', ');
      _selectedBarangay = data['location'];
    } else {
      _companyController.clear();
      _titleController.clear();
      _descriptionController.clear();
      _requirementsController.clear();
      _skillsController.clear();
      _selectedBarangay = barangays.first;
    }

    showDialog(
      context: context,
      builder: (_) {
        final isWide = MediaQuery.of(context).size.width > 600;
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: isWide ? 500 : double.infinity,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      doc == null ? 'Add Job Posting' : 'Edit Job Posting',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_companyController, 'Company Name'),
                    _buildTextField(_titleController, 'Job Title'),
                    _buildTextField(_descriptionController, 'Job Description', maxLines: 3),
                    _buildTextField(_requirementsController, 'Requirements'),
                    _buildTextField(_skillsController, 'Required Skills (comma-separated)'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedBarangay,
                      decoration: const InputDecoration(
                        labelText: 'Barangay',
                        border: OutlineInputBorder(),
                      ),
                      items: barangays.map((b) {
                        return DropdownMenuItem(value: b, child: Text(b));
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedBarangay = v),
                      validator: (v) => v == null || v == 'Barangays' ? 'Select a barangay' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _postOrUpdateJob(doc),
                      child: Text(doc == null ? 'Post Job' : 'Update Job'),
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

  Future<void> _postOrUpdateJob(DocumentSnapshot? doc) async {
    if (!_formKey.currentState!.validate()) return;

    final jobData = {
      'title': _titleController.text.trim(),
      'company': _companyController.text.trim(),
      'description': _descriptionController.text.trim(),
      'requirements': _requirementsController.text.trim(),
      'requiredSkills': _skillsController.text
          .trim()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'location': _selectedBarangay,
      'postedDate': Timestamp.now(),
    };

    try {
      if (doc == null) {
        await FirebaseFirestore.instance.collection('jobs').add(jobData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted successfully!')));
      } else {
        await doc.reference.update(jobData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job updated successfully!')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteJob(DocumentSnapshot doc) async {
    try {
      await doc.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Search + Barangay filter container with red background
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search job details...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (v) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (isWide)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: DropdownButtonFormField<String>(
                                value: _selectedBarangay ?? 'Barangays',
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                items: barangays.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                                onChanged: (v) => setState(() => _selectedBarangay = v),
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: _openBarangayDialog,
                            ),
                        ],
                      ),
                    ),

                    // Divider line with padding
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1.2,
                      ),
                    ),

                    // Job list container with blue background
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('jobs')
                              .orderBy('postedDate', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final docs = snapshot.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final keyword = _searchController.text.toLowerCase();
                              final allContent = (
                                  data['title'] +
                                      data['company'] +
                                      data['description'] +
                                      data['requirements'] +
                                      (data['requiredSkills'] as List).join(','))
                                  .toLowerCase();
                              final matchesSearch =
                                  keyword.isEmpty || allContent.contains(keyword);
                              final matchesBarangay = _selectedBarangay == null ||
                                  _selectedBarangay == 'Barangays'
                                  ? true
                                  : data['location'] == _selectedBarangay;
                              return matchesSearch && matchesBarangay;
                            }).toList();

                            if (docs.isEmpty) {
                              return const Center(child: Text('No matching job postings'));
                            }

                            return AnimationLimiter(
                              child: ListView.builder(
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  final data = doc.data() as Map<String, dynamic>;
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 300),
                                    child: SlideAnimation(
                                      verticalOffset: 50,
                                      child: FadeInAnimation(
                                        child: Center(
                                          child: Container(
                                            constraints: const BoxConstraints(maxWidth: 800),
                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                            child: Card(
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  'Job Title: ${data['title']}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Company Name: ${data['company']}', overflow: TextOverflow.ellipsis),
                                                    Text('Description: ${data['description']}', overflow: TextOverflow.ellipsis,),
                                                    Text('Requirements: ${data['requirements']}', overflow: TextOverflow.ellipsis),
                                                    Text('Barangay: ${data['location']}', overflow: TextOverflow.ellipsis),
                                                    Text('Skills: ${(data['requiredSkills'] as List<dynamic>).join(', ')}', overflow: TextOverflow.ellipsis),
                                                    const SizedBox(height: 4),
                                                    Text('Posted: ${(data['postedDate'] as Timestamp).toDate().toLocal().toString().split('.')[0]}'),
                                                  ],
                                                ),
                                                isThreeLine: true,
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit),
                                                      onPressed: () => _openJobForm(doc: doc),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete),
                                                      onPressed: () => _deleteJob(doc),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Add Job Button at Bottom Right inside container
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _openJobForm(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add Job", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red background
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}
