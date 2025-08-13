import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
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

    final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      final data = doc.data();
      final List<dynamic> appliedJobsData = data?['appliedJobs'] ?? [];

      setState(() {
        appliedJobIds = appliedJobsData.map<String>((entry) {
          if (entry is Map<String, dynamic>) {
            return entry['jobId'] as String? ?? '';
          }
          return '';
        }).where((id) => id.isNotEmpty).toList();
      });
    }
  }

  Future<void> _applyForJob(String jobId) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to apply.')),
      );
      return;
    }

    if (appliedJobIds.contains(jobId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already applied to this job.')),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      final userData = userDoc.data();

      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found.')),
        );
        return;
      }

      final resumeUrl = userData['resumeUrl'] as String?;

      if (resumeUrl == null || resumeUrl.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Resume Required'),
            content: const Text(
                'You need to upload your resume before applying for a job. Please update your profile with your resume.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
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

      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'appliedJobs': FieldValue.arrayUnion([
          {'jobId': jobId, 'appliedAt': appliedAt}
        ]),
      });

      final applicantInfo = {
        'uid': currentUser!.uid,
        'fullName': userData['fullName'] ?? '',
        'email': userData['email'] ?? '',
        'resumeUrl': resumeUrl,
        'appliedAt': appliedAt,
      };

      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'applicants': FieldValue.arrayUnion([applicantInfo]),
      });

      setState(() {
        appliedJobIds.add(jobId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Applied to job successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply: $e')),
      );
    }
  }

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

  void _showJobDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.work_outline, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data['title'] ?? 'Job Details',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(), // label column
                  1: FlexColumnWidth(), // value column
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                          onChanged: (v) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isWide)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: DropdownButtonFormField<String>(
                            value: _selectedBarangay ?? 'Barangays',
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            items: barangays.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                            onChanged: (v) => setState(() => _selectedBarangay = v),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.filter_list, size: 28),
                          tooltip: 'Select Barangay',
                          onPressed: _openBarangayDialog,
                        ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey, thickness: 1.2),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                  (data['requiredSkills'] as List).join(',')
                          ).toLowerCase();
                          final matchesSearch = keyword.isEmpty || allContent.contains(keyword);
                          final matchesBarangay = _selectedBarangay == null ||
                              _selectedBarangay == 'Barangays'
                              ? true
                              : data['location'] == _selectedBarangay;
                          return matchesSearch && matchesBarangay;
                        }).toList();

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No matching job postings',
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                          );
                        }

                        return AnimationLimiter(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final jobId = doc.id;
                              final alreadyApplied = appliedJobIds.contains(jobId);

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 350),
                                child: SlideAnimation(
                                  verticalOffset: 50,
                                  child: FadeInAnimation(
                                    child: Center(
                                      child: Container(
                                        constraints: const BoxConstraints(maxWidth: 800),
                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (isWide)
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          data['title'],
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 20,
                                                            color: Colors.blueAccent,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: alreadyApplied ? null : () => _applyForJob(jobId),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: alreadyApplied ? Colors.grey : Colors.red.shade700,
                                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              alreadyApplied ? 'Applied' : 'Apply',
                                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          ElevatedButton.icon(
                                                            onPressed: () => _showJobDetailsDialog(data),
                                                            icon: const Icon(Icons.info_outline, color: Colors.white),
                                                            label: const Text('View Details', style: TextStyle(color: Colors.white)),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.red,
                                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  Text(
                                                    data['title'],
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.blueAccent,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                const SizedBox(height: 6),
                                                Text('Company: ${data['company']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                                Text('Barangay: ${data['location']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Posted: ${(data['postedDate'] as Timestamp).toDate().toLocal().toString().split('.')[0]}',
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                                const SizedBox(height: 12),
                                                if (!isWide)
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: alreadyApplied ? null : () => _applyForJob(jobId),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: alreadyApplied ? Colors.grey : Colors.red.shade700,
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          alreadyApplied ? 'Applied' : 'Apply',
                                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      ElevatedButton.icon(
                                                        onPressed: () => _showJobDetailsDialog(data),
                                                        icon: const Icon(Icons.info_outline, color: Colors.white),
                                                        label: const Text('View Details', style: TextStyle(color: Colors.white)),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
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
          ),
        ),
      ),
    );
  }
}