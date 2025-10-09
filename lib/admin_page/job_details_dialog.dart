import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailsDialog extends StatelessWidget {
  final DocumentSnapshot doc;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JobDetailsDialog({
    Key? key,
    required this.doc,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 400, vertical: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Company: ${data['company'] ?? ''}"),
              Text("Location: ${data['location'] ?? 'Not specified'}"),
              Text("Education: ${data['educationLevel'] ?? 'Not specified'}"),
              Text("Employment Type: ${data['employmentType'] ?? 'Not specified'}"),
              if (data['salaryMin'] != null && data['salaryMax'] != null)
                Text("Salary: ₱${data['salaryMin']} - ₱${data['salaryMax']}"),
              if (data['deadline'] != null)
                Text("Deadline: ${(data['deadline'] as dynamic).toDate().toLocal()}"),
              const Divider(height: 24),
              Text("Description: ${data['description'] ?? ''}"),
              const SizedBox(height: 8),
              Text("Requirements: ${data['requirements'] ?? ''}"),
              const SizedBox(height: 8),
              Text("Skills: ${(data['requiredSkills'] as List<dynamic>?)?.join(', ') ?? ''}"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit), label: const Text("Edit")),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
