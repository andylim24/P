import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Page3Admin extends StatefulWidget {
  const Page3Admin({super.key});

  @override
  State<Page3Admin> createState() => _Page3AdminState();
}

class _Page3AdminState extends State<Page3Admin> {
  final ScrollController _jobSeekerScrollController = ScrollController();
  final ScrollController _adminScrollController = ScrollController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _jobSeekers = [];
  List<Map<String, dynamic>> _employers = [];
  String _searchQuery = '';

  // Summary statistics
  int totalJobSeekers = 0;
  int totalApplications = 0;
  int totalHired = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _jobSeekerScrollController.dispose();
    _adminScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadJobSeekers(),
        _loadEmployers(),
      ]);
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadJobSeekers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> jobSeekers = [];
    int appCount = 0;
    int hiredCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final appliedJobs = data['appliedJobs'] as List<dynamic>? ?? [];

      // Count applications and hired status
      appCount += appliedJobs.length;
      for (final job in appliedJobs) {
        if (job is Map<String, dynamic> && job['status']?.toString().toLowerCase() == 'hired') {
          hiredCount++;
        }
      }

      // Get the most recent application status
      String lastStatus = 'No Applications';
      String lastAppliedJob = '-';
      if (appliedJobs.isNotEmpty) {
        final lastJob = appliedJobs.last;
        if (lastJob is Map<String, dynamic>) {
          lastStatus = lastJob['status'] ?? 'Pending';
          lastAppliedJob = lastJob['jobId'] ?? '-';
        }
      }

      jobSeekers.add({
        'id': doc.id,
        'name': data['fullName'] ?? data['firstName'] ?? 'Unknown',
        'email': data['email'] ?? '-',
        'phone': data['mobileNumber'] ?? data['phone'] ?? '-',
        'appliedCount': appliedJobs.length,
        'lastApplied': lastAppliedJob,
        'status': lastStatus,
        'dateJoined': _formatTimestamp(data['createdAt']),
        'lastLogin': _formatTimestamp(data['lastLogin']),
      });
    }

    setState(() {
      _jobSeekers = jobSeekers;
      totalJobSeekers = jobSeekers.length;
      totalApplications = appCount;
      totalHired = hiredCount;
    });
  }

  Future<void> _loadEmployers() async {
    // Load employer registrations instead of admins
    try {
      final snapshot = await FirebaseFirestore.instance.collection('employer_registrations').get();

      List<Map<String, dynamic>> employers = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        employers.add({
          'id': doc.id,
          'companyName': data['companyName'] ?? '-',
          'contactPerson': data['contactPerson'] ?? '-',
          'contactNumber': data['contactNumber'] ?? '-',
          'status': data['status'] ?? 'pending',
          'createdAt': _formatTimestamp(data['createdAt']),
          'documents': data['documents'] ?? {},
        });
      }

      setState(() {
        _employers = employers;
      });
    } catch (e) {
      // If collection doesn't exist or error, use empty list
      setState(() {
        _employers = [];
      });
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return timestamp.toString();
  }

  List<Map<String, dynamic>> get _filteredJobSeekers {
    if (_searchQuery.isEmpty) return _jobSeekers;
    final query = _searchQuery.toLowerCase();
    return _jobSeekers.where((js) {
      return js['name'].toString().toLowerCase().contains(query) ||
          js['email'].toString().toLowerCase().contains(query) ||
          js['phone'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.red),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Container(
                color: Colors.grey[50],
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 40,
                    vertical: isMobile ? 16 : 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Stats Cards
                      _buildStatCards(isMobile),
                      const SizedBox(height: 24),

                      // Job Seeker Table
                      _buildJobSeekerTable(isMobile),
                      const SizedBox(height: 30),

                      // Admin Table
                      _buildAdminTable(isMobile),
                      const SizedBox(height: 40),

                      // Summary Chart
                      const Text(
                        "Summary: Users vs Applications vs Hires",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: isMobile ? 200 : 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: _buildSummaryBarChart(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendItem(Colors.indigo, "Job Seekers"),
                          const SizedBox(width: 20),
                          _legendItem(Colors.green, "Applications"),
                          const SizedBox(width: 20),
                          _legendItem(Colors.orange, "Hired"),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCards(bool isMobile) {
    final cards = [
      {'title': 'Total Job Seekers', 'value': totalJobSeekers.toString(), 'icon': Icons.people, 'color': Colors.blue},
      {'title': 'Total Applications', 'value': totalApplications.toString(), 'icon': Icons.assignment, 'color': Colors.green},
      {'title': 'Total Hired', 'value': totalHired.toString(), 'icon': Icons.check_circle, 'color': Colors.orange},
    ];

    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return _buildStatCard(
            card['title'] as String,
            card['value'] as String,
            card['icon'] as IconData,
            card['color'] as Color,
          );
        },
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: cards.map((card) => _buildStatCard(
        card['title'] as String,
        card['value'] as String,
        card['icon'] as IconData,
        card['color'] as Color,
      )).toList(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSeekerTable(bool isMobile) {
    final filteredData = _filteredJobSeekers;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Job Seekers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: "Search by name, email, or phone...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            if (filteredData.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No job seekers found')),
              )
            else
              Scrollbar(
                controller: _jobSeekerScrollController,
                thumbVisibility: true,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _jobSeekerScrollController,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 900),
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateProperty.all(Colors.indigo[50]),
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey[300]!),
                      ),
                      columns: const [
                        DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Email", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Phone", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Applications", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Date Joined", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                      rows: filteredData.map((js) => DataRow(
                        cells: [
                          DataCell(Text(js['name'])),
                          DataCell(Text(js['email'], overflow: TextOverflow.ellipsis)),
                          DataCell(Text(js['phone'])),
                          DataCell(Text(js['appliedCount'].toString())),
                          DataCell(Text(js['dateJoined'])),
                          DataCell(TextButton(onPressed: () => _showUserProfile(js['id']), child: const Text('View'))),
                        ],
                      )).toList(),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Showing ${filteredData.length} of ${_jobSeekers.length} records",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'hired':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'interviewing':
      case 'shortlisted':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAdminTable(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Employer Registrations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 16),
            if (_employers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No employer registrations found')),
              )
            else
              Scrollbar(
                controller: _adminScrollController,
                thumbVisibility: true,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _adminScrollController,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 700),
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowColor: MaterialStateProperty.all(Colors.indigo[50]),
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey[300]!),
                      ),
                      columns: const [
                        DataColumn(label: Text("Company", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Contact", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Phone", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Registered", style: TextStyle(fontWeight: FontWeight.w600))),
                        DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                      rows: _employers.map((emp) => DataRow(
                        cells: [
                          DataCell(Text(emp['companyName'] ?? '-')),
                          DataCell(Text(emp['contactPerson'] ?? '-')),
                          DataCell(Text(emp['contactNumber'] ?? '-')),
                          DataCell(_buildStatusBadge(emp['status'] ?? 'pending')),
                          DataCell(Text(emp['createdAt'] ?? '-')),
                          DataCell(TextButton(
                            onPressed: () => _showEmployerDocuments(emp),
                            child: const Text('View'),
                          )),
                        ],
                      )).toList(),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Showing ${_employers.length} records",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBarChart() {
    final maxY = [totalJobSeekers.toDouble(), totalApplications.toDouble(), totalHired.toDouble()]
        .reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxY < 10 ? 10.0 : maxY * 1.2;

    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: totalJobSeekers.toDouble(),
                color: Colors.indigo,
                width: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: totalApplications.toDouble(),
                color: Colors.green,
                width: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: totalHired.toDouble(),
                color: Colors.orange,
                width: 24,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
        maxY: chartMaxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final labels = ['Job Seekers', 'Applications', 'Hired'];
              return BarTooltipItem(
                '${labels[group.x]}\n${rod.toY.toInt()}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Job Seekers', 'Applications', 'Hired'];
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      titles[value.toInt()],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: chartMaxY < 10 ? 2 : (chartMaxY / 5).ceilToDouble(),
              reservedSize: 40,
              getTitlesWidget: (value, meta) =>
                  Text(value.toInt().toString(), style: const TextStyle(fontSize: 11)),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildActionsDropdown(String id, String type) {
    final actions = type == 'jobseeker'
        ? ['View Profile', 'Delete', 'Suspend']
        : ['Edit Role', 'Deactivate', 'Reset Password'];

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) =>
          actions.map((a) => PopupMenuItem(value: a, child: Text(a))).toList(),
      onSelected: (value) => _handleAction(value, id, type),
    );
  }

  void _handleAction(String action, String id, String type) {
    switch (action) {
      case 'View Profile':
        _showUserProfile(id);
        break;
      case 'Delete':
        _confirmDelete(id, type);
        break;
      case 'Suspend':
      case 'Deactivate':
        _confirmSuspend(id, type);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action: $id')),
        );
    }
  }

  void _showUserProfile(String userId) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return AlertDialog(
              title: const Text('User Not Found'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Make a mutable copy of appliedJobs so we can update statuses locally
          final List<Map<String, dynamic>> applications =
              ((data['appliedJobs'] as List?) ?? [])
                  .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
                  .toList();

          return AlertDialog(
            title: Text(data['fullName'] ?? 'User Profile'),
            content: StatefulBuilder(
              builder: (context, setStateDialog) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Resume', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if ((data['resumeUrl'] as String?)?.isNotEmpty ?? false)
                        TextButton(
                          onPressed: () async {
                            final url = data['resumeUrl'] as String;
                            try {
                              final uri = Uri.parse(url);
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open resume')),
                              );
                            }
                          },
                          child: const Text('Open Resume'),
                        )
                      else
                        const Text('No resume uploaded'),

                      const SizedBox(height: 12),
                      const Text('Applications', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (applications.isEmpty)
                        const Text('No applications found')
                      else
                        Column(
                          children: List.generate(applications.length, (i) {
                            final app = applications[i];
                            final jobId = app['jobId']?.toString() ?? '-';
                            final jobTitle = app['jobTitle']?.toString() ?? jobId;
                            final status = app['status']?.toString() ?? 'Pending';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(jobTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Text('Job ID: $jobId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatusBadge(status),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.edit),
                                      itemBuilder: (context) => ['Pending', 'Hired']
                                          .map((s) => PopupMenuItem(value: s, child: Text(s)))
                                          .toList(),
                                      onSelected: (newStatus) async {
                                        if (newStatus == status) return;
                                        // Update local copy
                                        applications[i]['status'] = newStatus;
                                        setStateDialog(() {});

                                        // Persist to Firestore: overwrite appliedJobs for this user
                                        try {
                                          await FirebaseFirestore.instance.collection('users').doc(userId).update({
                                            'appliedJobs': applications,
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Application status updated to $newStatus')),
                                          );
                                          // Refresh main dashboard stats
                                          await _loadData();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to update status: $e')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final collection = type == 'jobseeker' ? 'users' : 'admins';
                await FirebaseFirestore.instance.collection(collection).doc(id).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
                );
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting user: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmSuspend(String id, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Suspend'),
        content: const Text('Are you sure you want to suspend this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final collection = type == 'jobseeker' ? 'users' : 'admins';
                await FirebaseFirestore.instance.collection(collection).doc(id).update({
                  'status': 'Suspended',
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User suspended successfully')),
                );
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error suspending user: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Suspend', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEmployerDocuments(Map<String, dynamic> emp) {
    final docs = emp['documents'] as Map<String, dynamic>? ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(emp['companyName'] ?? 'Employer Documents'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (docs.isEmpty) const Text('No documents attached')
              else
                ...docs.entries.map((e) {
                  final key = e.key;
                  final url = e.value?.toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(key)),
                        if (url != null && url.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              try {
                                final uri = Uri.parse(url);
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open document')),
                                );
                              }
                            },
                            child: const Text('Open'),
                          )
                        else
                          const Text('-'),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
