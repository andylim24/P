import 'package:flutter/material.dart';

class JobListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color bgColor;
  final String initials;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JobListItem({
    Key? key,
    required this.data,
    required this.bgColor,
    required this.initials,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo or placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              image: (data['logoUrl'] != null && data['logoUrl'].toString().isNotEmpty)
                  ? DecorationImage(
                image: NetworkImage(data['logoUrl']),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: (data['logoUrl'] == null || data['logoUrl'].toString().isEmpty)
                ? Center(
              child: Text(
                initials,
                style: const TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            )
                : null,
          ),
          const SizedBox(width: 16),

          // Job info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  data['company'] ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      data['location'] ?? 'Location not specified',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      data['educationLevel'] ?? 'Educ level not specified',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.work, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      data['employmentType'] ?? 'Type not specified',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Salary + Date + Edit/Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (data['salaryMin'] != null && data['salaryMax'] != null)
                    ? "₱${data['salaryMin']} - ₱${data['salaryMax']}"
                    : "Salary not specified",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    (data['postedDate'] as dynamic)
                        .toDate()
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
