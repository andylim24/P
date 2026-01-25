import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 1200,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PESO MAKATI Latest News",
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('date', descending: true)
                    .limit(4)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No announcements yet.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final mainAnnouncement =
                      docs.first.data() as Map<String, dynamic>;
                  final sideAnnouncements = docs.skip(1).toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;

                      return Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isWide
                              ? Expanded(
                                  flex: 2,
                                  child: _buildMainCard(mainAnnouncement, false),
                                )
                              : _buildMainCard(mainAnnouncement, true),

                          isWide
                              ? Expanded(
                                  flex: 1,
                                  child: _buildSideCards(sideAnnouncements),
                                )
                              : _buildSideCards(sideAnnouncements),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== MAIN CARD =====================
  Widget _buildMainCard(Map<String, dynamic> data, bool isMobile) {
    // Use compact card style for mobile
    if (isMobile) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(
                data['imageUrl'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['description'] ?? 'No description.',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '📅 ${_formatDate(data)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Desktop version
    return Container(
      margin: const EdgeInsets.only(right: 20, bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 220,
              height: 300,
              color: Colors.grey[100],
              child: _buildImage(
                data['imageUrl'],
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // RIGHT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  data['description'] ?? 'No description available.',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (data['location'] != null &&
                        data['location'].toString().isNotEmpty)
                      Text(
                        '📍 ${data['location']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    const SizedBox(width: 16),
                    Text(
                      '📅 ${_formatDate(data)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== SIDE CARDS =====================
  Widget _buildSideCards(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return const SizedBox.shrink();

    return Column(
      children: docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(
                  data['imageUrl'],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['description'] ?? 'No description.',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📅 ${_formatDate(data)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===================== IMAGE BUILDER =====================
  Widget _buildImage(
    String? imageUrl, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.contain,
  }) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _fallbackImage(height: height, width: width, fit: fit);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    return _fallbackImage(height: height, width: width, fit: fit);
  }

  Widget _fallbackImage({
    double? height,
    double? width,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.asset(
      'assets/images/announcement.png',
      height: height,
      width: width,
      fit: fit,
    );
  }

  // ===================== DATE FORMATTER =====================
  String _formatDate(Map<String, dynamic> data) {
    // First check for dateDisplay (formatted string)
    if (data['dateDisplay'] != null &&
        data['dateDisplay'].toString().isNotEmpty) {
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
  }
}