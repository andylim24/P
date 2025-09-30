import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppliedJobsSection extends StatefulWidget {
  const AppliedJobsSection({super.key});

  @override
  State<AppliedJobsSection> createState() => _AppliedJobsSectionState();
}

class _AppliedJobsSectionState extends State<AppliedJobsSection> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> appliedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadAppliedJobs();
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
              Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
              }),
          ],
        ),
      ),
    );
  }


}
