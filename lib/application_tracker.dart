import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_homepage.dart';

class ApplicationTracker extends StatefulWidget {
  const ApplicationTracker({super.key});

  @override
  State<ApplicationTracker> createState() => _ApplicationTrackerState();
}

class _ApplicationTrackerState extends State<ApplicationTracker> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> appliedJobs = [];

  int pendingCount = 0;
  int acceptedCount = 0;

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
          final status = entry['status'] ?? 'Pending';

          jobsWithAppliedDate.add({
            'job': jobData,
            'appliedAt': appliedAt,
            'status': status,
          });
        }
      }
    }

    jobsWithAppliedDate.sort((a, b) {
      final aDate = (a['appliedAt'] as Timestamp).toDate();
      final bDate = (b['appliedAt'] as Timestamp).toDate();
      return bDate.compareTo(aDate);
    });

    int pCount = 0;
    int aCount = 0;
    for (var e in jobsWithAppliedDate) {
      if ((e['status'] as String).toLowerCase() == 'accepted') {
        aCount++;
      } else {
        pCount++;
      }
    }

    setState(() {
      appliedJobs = jobsWithAppliedDate;
      pendingCount = pCount;
      acceptedCount = aCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color headerColor = Colors.blueGrey.shade800;
    final Color oddRowColor = Colors.grey.shade50;
    final Color evenRowColor = Colors.grey.shade100;
    final borderRadius = BorderRadius.circular(12);

    return MainScaffold(
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue[900]!],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoBox('Total Applied Jobs', appliedJobs.length.toString(), Colors.blue),
                        _infoBox('Pending Applications', pendingCount.toString(), Colors.orange),
                        _infoBox('Accepted Applications', acceptedCount.toString(), Colors.green),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text('Applied Jobs', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),

                    // Table header
                    Container(
                      decoration: BoxDecoration(
                        color: headerColor,
                        borderRadius: borderRadius,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Company', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Job Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Date Applied', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (appliedJobs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: oddRowColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Center(child: Text('No jobs applied yet.', style: TextStyle(fontSize: 16))),
                      )
                    else
                      Column(
                        children: appliedJobs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final job = data['job'] as Map<String, dynamic>;
                          final appliedAt = data['appliedAt'] as Timestamp;
                          final status = data['status'] as String;

                          final rowColor = index.isEven ? evenRowColor : oddRowColor;

                          return Container(
                            decoration: BoxDecoration(
                              color: rowColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: index == appliedJobs.length - 1 ? Radius.circular(12) : Radius.zero,
                                bottomRight: index == appliedJobs.length - 1 ? Radius.circular(12) : Radius.zero,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(job['company'] ?? 'Unknown')),
                                Expanded(flex: 3, child: Text(job['title'] ?? 'No title')),
                                Expanded(flex: 2, child: Text(appliedAt.toDate().toLocal().toString().split(' ')[0])),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: status.toLowerCase() == 'accepted'
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: status.toLowerCase() == 'accepted'
                                            ? Colors.green.shade800
                                            : Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
