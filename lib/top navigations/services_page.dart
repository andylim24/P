import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../main_homepage.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final double maxListWidth = 1000;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/homebackground.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
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
                        "Announcements\n\nStay updated with the latest news, events, and important information posted by the admin.",
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

                // Announcements List
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxListWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Announcements",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 600,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('announcements')
                                  .orderBy('date', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }

                                final docs = snapshot.data?.docs ?? [];
                                if (docs.isEmpty) {
                                  return const Text(
                                    'No announcements yet.',
                                    style: TextStyle(color: Colors.white),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final doc = docs[index];
                                    final data = doc.data() as Map<String, dynamic>;

                                    return Card(
                                      color: Colors.white.withOpacity(0.9),
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Left section: Text info
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data['title'] ?? 'No Title',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    data['description'] ?? 'No Description',
                                                    style: TextStyle(color: Colors.grey[800]),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '📍 ${data['location'] ?? 'No location'}',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                  ),
                                                  Text(
                    '📅 ${_formatDate(data)}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                                                ],
                                              ),
                                            ),

                                            // Right section: Image if exists
                                            if (data['imageUrl'] != null &&
                                                data['imageUrl'].toString().isNotEmpty) ...[
                                              const SizedBox(width: 16),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                  data['imageUrl'],
                                                  height: 100,
                                                  width: 140,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/announcement.png',
                                                      height: 100,
                                                      width: 140,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
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
   String _formatDate(Map<String, dynamic> data) {
    // First check for dateDisplay (formatted string)
    if (data['dateDisplay'] != null && data['dateDisplay'].toString().isNotEmpty) {
      return data['dateDisplay'];
    }
    // Then check for Timestamp
    if (data['date'] is Timestamp) {
      final d = (data['date'] as Timestamp).toDate();
      return '${d.day}/${d.month}/${d.year}';
    }
    // Fallback to string date
    if (data['date'] != null && data['date'].toString().isNotEmpty) {
      return data['date'].toString();
    }
    return 'No date';
  }}