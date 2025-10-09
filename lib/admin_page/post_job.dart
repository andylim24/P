import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'job_details_dialog.dart';
import 'job_form_dialog.dart';
import 'job_list_item.dart';

class JobsPageAdmin extends StatefulWidget {
  const JobsPageAdmin({Key? key}) : super(key: key);

  @override
  State<JobsPageAdmin> createState() => _JobsPageAdminState();
}

class _JobsPageAdminState extends State<JobsPageAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Delete job
  Future<void> _deleteJob(DocumentSnapshot doc) async {
    await _firestore.collection('jobs').doc(doc.id).delete();
  }

  /// Open add/edit form
  void _openJobForm({DocumentSnapshot? doc}) {
    showDialog(
      context: context,
      builder: (_) => JobFormDialog(doc: doc),
    );
  }

  /// View job details
  void _viewJobDetails(DocumentSnapshot doc, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => JobDetailsDialog(
        doc: doc,
        data: data,
        onEdit: () {
          Navigator.pop(context);
          _openJobForm(doc: doc);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteJob(doc);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Job Listings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openJobForm(),
                icon: const Icon(Icons.add),
                label: const Text("Add Job"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🔹 Job Listings Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('jobs')
                  .orderBy('postedDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("No jobs posted yet"));
                }

                // 🔹 Display job cards
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 1000 ? screenWidth * 0.15 : 20,
                    vertical: 10,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final bgColor = colors[index % colors.length];
                    final initials = (data['company'] != null &&
                        data['company'].toString().isNotEmpty)
                        ? data['company'].toString().trim()[0].toUpperCase()
                        : '?';

                    return InkWell(
                      onTap: () => _viewJobDetails(doc, data),
                      child: JobListItem(
                        data: data,
                        bgColor: bgColor,
                        initials: initials,
                        onEdit: () => _openJobForm(doc: doc),
                        onDelete: () => _deleteJob(doc),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
