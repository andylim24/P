import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main_homepage.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBarangay;
  String? _selectedEmploymentType;
  String? _selectedEducationLevel;
  bool _pwdOnly = false;
  bool _spesOnly = false;
  bool _mipOnly = false;

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

  final List<String> employmentTypes = [
    'Employment Type',
    'Contractual',
    'Permanent',
    'Project-based',
    'Work from home'
  ];

  final List<String> educationLevels = [
    'Education Level',
    'High School',
    'College Graduate',
    "Master's",
    'Doctorate'
  ];

  User? currentUser;
  List<String> appliedJobIds = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _loadAppliedJobs();
  }

  Future<void> _loadAppliedJobs() async {
    if (currentUser == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    if (doc.exists) {
      final data = doc.data();
      final List<dynamic> appliedJobsData = data?['appliedJobs'] ?? [];
      setState(() {
        appliedJobIds = appliedJobsData
            .map<String>((entry) {
          if (entry is Map<String, dynamic>) return entry['jobId'] ?? '';
          return '';
        })
            .where((id) => id.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _applyForJob(String jobId) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to apply.')));
      return;
    }

    if (appliedJobIds.contains(jobId)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already applied to this job.')));
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      final userData = userDoc.data();

      if (userData == null ||
          userData['resumeUrl'] == null ||
          userData['resumeUrl'].isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Resume Required'),
            content: const Text(
                'Please upload your resume before applying for jobs.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
                child: const Text('Upload Resume'),
              ),
            ],
          ),
        );
        return;
      }

      final appliedAt = Timestamp.now();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'appliedJobs':
        FieldValue.arrayUnion([{'jobId': jobId, 'appliedAt': appliedAt}])
      });

      final applicantInfo = {
        'uid': currentUser!.uid,
        'fullName': userData['fullName'] ?? '',
        'email': userData['email'] ?? '',
        'resumeUrl': userData['resumeUrl'],
        'appliedAt': appliedAt,
      };

      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .update({
        'applicants': FieldValue.arrayUnion([applicantInfo]),
      });

      setState(() => appliedJobIds.add(jobId));

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Applied successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to apply: $e')));
    }
  }

  void _showJobDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.work_outline, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data['title'] ?? 'Job Details',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Company: ${data['company']}"),
                  Text("Location: ${data['location']}"),
                  Text(
                      "Education Level: ${data['educationLevel'] ?? 'Not specified'}"),
                  Text(
                      "Employment Type: ${data['employmentType'] ?? 'Not specified'}"),
                  if (data['salaryMin'] != null && data['salaryMax'] != null)
                    Text("Salary: ₱${data['salaryMin']} - ₱${data['salaryMax']}"),
                  Text("Description: ${data['description'] ?? ''}"),
                  Text("Requirements: ${data['requirements'] ?? ''}"),
                  Text(
                      "Skills: ${(data['requiredSkills'] as List).join(', ')}"),
                  Text(
                      "Posted: ${(data['postedDate'] as Timestamp).toDate().toLocal()}"),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Stack(
        children: [
          // background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/homebackground.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          // 🔹 scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Full-width banner
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue[900]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Welcome to the Job Listings Page!\n\nHere you can explore job opportunities from different employers in Makati.\nUse the search and filters below to quickly find jobs that match your skills and preferences.",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // 🔹 Filters + Job Listings
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // 🔹 Search + Info Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
                            Text('Find jobs here',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                            SizedBox(height: 4),
                            Text(
                              'You may search by position title, employer name, work location, education level or course, etc.',
                              style:
                              TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),

                        // 🔹 Search + Barangay filter
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search job details...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (v) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: DropdownButtonFormField<String>(
                                value: _selectedBarangay ?? 'Barangays',
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                items: barangays
                                    .map((b) => DropdownMenuItem(
                                    value: b, child: Text(b)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedBarangay = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 🔹 Employment + Education + Checkboxes
                        Row(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: DropdownButtonFormField<String>(
                                value:
                                _selectedEmploymentType ?? 'Employment Type',
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                items: employmentTypes
                                    .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedEmploymentType = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: DropdownButtonFormField<String>(
                                value:
                                _selectedEducationLevel ?? 'Education Level',
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                items: educationLevels
                                    .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedEducationLevel = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _spesOnly,
                                  onChanged: (v) =>
                                      setState(() => _spesOnly = v!),
                                ),
                                const Text('SPES',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _mipOnly,
                                  onChanged: (v) =>
                                      setState(() => _mipOnly = v!),
                                ),
                                const Text('MIP',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _pwdOnly,
                                  onChanged: (v) =>
                                      setState(() => _pwdOnly = v!),
                                ),
                                const Text('PWD',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),

                        // 🔹 Job Listings
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('jobs')
                              .orderBy('postedDate', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final docs = snapshot.data!.docs.where((doc) {
                              final data =
                              doc.data() as Map<String, dynamic>;
                              final keyword =
                              _searchController.text.toLowerCase();

                              final allContent = ((data['title'] ?? '') +
                                  (data['company'] ?? '') +
                                  (data['description'] ?? '') +
                                  (data['requirements'] ?? '') +
                                  ((data['requiredSkills']
                                  as List<dynamic>?)
                                      ?.join(',') ??
                                      ''))
                                  .toLowerCase();

                              final matchesSearch = keyword.isEmpty ||
                                  allContent.contains(keyword);
                              final matchesBarangay = (_selectedBarangay ==
                                  null ||
                                  _selectedBarangay == 'Barangays')
                                  ? true
                                  : (data['location'] ?? '')
                                  .toLowerCase() ==
                                  _selectedBarangay!.toLowerCase();

                              final matchesEmployment =
                              (_selectedEmploymentType == null ||
                                  _selectedEmploymentType ==
                                      'Employment Type')
                                  ? true
                                  : (data['employmentType'] ?? '')
                                  .toLowerCase() ==
                                  _selectedEmploymentType!
                                      .toLowerCase();

                              final matchesEducation =
                              (_selectedEducationLevel == null ||
                                  _selectedEducationLevel ==
                                      'Education Level')
                                  ? true
                                  : (data['educationLevel'] ?? '')
                                  .toLowerCase() ==
                                  _selectedEducationLevel!
                                      .toLowerCase();

                              final matchesPWD = !_pwdOnly
                                  ? true
                                  : ((data['description'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains('pwd') ||
                                  (data['requirements'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .contains('pwd'));
                              final matchesSPES = !_spesOnly
                                  ? true
                                  : ((data['description'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains('spes') ||
                                  (data['requirements'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .contains('spes'));
                              final matchesMIP = !_mipOnly
                                  ? true
                                  : ((data['description'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains('mip') ||
                                  (data['requirements'] ?? '')
                                      .toString()
                                      .toLowerCase()
                                      .contains('mip'));

                              return matchesSearch &&
                                  matchesBarangay &&
                                  matchesEmployment &&
                                  matchesEducation &&
                                  matchesPWD &&
                                  matchesMIP &&
                                  matchesSPES;
                            }).toList();

                            if (docs.isEmpty) {
                              return const Center(child: Text('No jobs found'));
                            }

                            final colors = [
                              Colors.blue,
                              Colors.green,
                              Colors.orange,
                              Colors.purple,
                              Colors.red
                            ];

                            return Column(
                              children: docs.map((doc) {
                                final data =
                                doc.data() as Map<String, dynamic>;
                                final jobId = doc.id;
                                final bgColor =
                                colors[docs.indexOf(doc) % colors.length];
                                final initials = (data['company'] != null &&
                                    data['company'].toString().isNotEmpty)
                                    ? data['company']
                                    .toString()
                                    .trim()[0]
                                    .toUpperCase()
                                    : '?';
                                final alreadyApplied =
                                appliedJobIds.contains(jobId);

                                return InkWell(
                                  onTap: () => _showJobDetailsDialog(data),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        // 🔹 Logo
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: bgColor.withOpacity(0.8),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            image: (data['logoUrl'] != null &&
                                                data['logoUrl']
                                                    .toString()
                                                    .isNotEmpty)
                                                ? DecorationImage(
                                                image: NetworkImage(
                                                    data['logoUrl']),
                                                fit: BoxFit.cover)
                                                : null,
                                          ),
                                          child: (data['logoUrl'] == null ||
                                              data['logoUrl']
                                                  .toString()
                                                  .isEmpty)
                                              ? Center(
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                          )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),

                                        // 🔹 Job Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(data['title'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Colors.blue)),
                                              const SizedBox(height: 4),
                                              Text(data['company'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                      data['location'] ??
                                                          'Not specified',
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                          Colors.black54)),
                                                  const SizedBox(width: 12),
                                                  const Icon(Icons.school,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                      data['educationLevel'] ??
                                                          'Not specified',
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                          Colors.black54)),
                                                ],
                                              ),
                                              if (data['salaryMin'] != null &&
                                                  data['salaryMax'] != null)
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 4.0),
                                                  child: Text(
                                                    "₱${data['salaryMin']} - ₱${data['salaryMax']}",
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                        Colors.black87),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        // 🔹 Apply Button
                                        ElevatedButton(
                                          onPressed: alreadyApplied
                                              ? null
                                              : () => _applyForJob(jobId),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: alreadyApplied
                                                ? Colors.grey
                                                : Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            alreadyApplied
                                                ? 'Applied'
                                                : 'Apply',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),

                      ],

                    ),

                  ),
                ),
              ],

            ),


          ),
        ],
      ),

    );
  }

}
