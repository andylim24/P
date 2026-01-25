import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPageAdmin extends StatefulWidget {
  const AdminDashboardPageAdmin({super.key});

  @override
  State<AdminDashboardPageAdmin> createState() => _AdminDashboardPageAdminState();
}

class _AdminDashboardPageAdminState extends State<AdminDashboardPageAdmin> {
  bool _isLoading = true;

  // Statistics
  int totalJobseekers = 0;
  int totalJobs = 0;
  int totalApplications = 0;
  int activeJobs = 0;

  // Monthly application data (last 6 months)
  Map<String, int> monthlyApplications = {};

  // Job categories data
  Map<String, int> jobCategories = {};

  // Recent jobs
  List<Map<String, dynamic>> recentJobs = [];

  // Recent applicants
  List<Map<String, dynamic>> recentApplicants = [];

  // Chart touch index for interactivity
  int touchedPieIndex = -1;
  int touchedBarIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch all data in parallel
      await Future.wait([
        _loadUserStats(),
        _loadJobStats(),
        _loadMonthlyApplications(),
        _loadRecentJobs(),
        _loadRecentApplicants(),
      ]);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadUserStats() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    int jobseekerCount = 0;
    int appCount = 0;

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      // Count users who have jobseeker profile data
      if (data['firstName'] != null || data['fullName'] != null) {
        jobseekerCount++;
      }
      // Count total applications
      final appliedJobs = data['appliedJobs'] as List<dynamic>? ?? [];
      appCount += appliedJobs.length;
    }

    setState(() {
      totalJobseekers = jobseekerCount;
      totalApplications = appCount;
    });
  }

  Future<void> _loadJobStats() async {
    final jobsSnapshot = await FirebaseFirestore.instance.collection('jobs').get();

    int jobCount = 0;
    int activeCount = 0;
    Map<String, int> categories = {};

    final now = DateTime.now();

    for (final doc in jobsSnapshot.docs) {
      final data = doc.data();
      jobCount++;

      // Check if job is still active (posted within last 30 days or has no expiry)
      final postedDate = (data['postedDate'] as Timestamp?)?.toDate();
      if (postedDate != null && now.difference(postedDate).inDays <= 30) {
        activeCount++;
      }

      // Count by category/industry
      final category = data['category'] as String? ?? data['industry'] as String? ?? 'Other';
      categories[category] = (categories[category] ?? 0) + 1;
    }

    setState(() {
      totalJobs = jobCount;
      activeJobs = activeCount;
      jobCategories = categories;
    });
  }

  Future<void> _loadMonthlyApplications() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    Map<String, int> monthly = {};
    final now = DateTime.now();

    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = _getMonthKey(month);
      monthly[key] = 0;
    }

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final appliedJobs = data['appliedJobs'] as List<dynamic>? ?? [];

      for (final job in appliedJobs) {
        if (job is Map<String, dynamic> && job['appliedAt'] != null) {
          final appliedAt = (job['appliedAt'] as Timestamp).toDate();
          final key = _getMonthKey(appliedAt);
          if (monthly.containsKey(key)) {
            monthly[key] = (monthly[key] ?? 0) + 1;
          }
        }
      }
    }

    setState(() {
      monthlyApplications = monthly;
    });
  }

  String _getMonthKey(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  Future<void> _loadRecentJobs() async {
    final jobsSnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .orderBy('postedDate', descending: true)
        .limit(5)
        .get();

    List<Map<String, dynamic>> jobs = [];
    for (final doc in jobsSnapshot.docs) {
      final data = doc.data();
      final applicants = data['applicants'] as List<dynamic>? ?? [];
      jobs.add({
        'id': doc.id,
        'title': data['title'] ?? 'Untitled',
        'company': data['company'] ?? 'Unknown',
        'applicantCount': applicants.length,
        'postedDate': data['postedDate'],
      });
    }

    setState(() {
      recentJobs = jobs;
    });
  }

  Future<void> _loadRecentApplicants() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> applicants = [];

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final appliedJobs = data['appliedJobs'] as List<dynamic>? ?? [];

      for (final job in appliedJobs) {
        if (job is Map<String, dynamic>) {
          applicants.add({
            'name': data['fullName'] ?? data['firstName'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'jobId': job['jobId'],
            'appliedAt': job['appliedAt'],
            'status': job['status'] ?? 'Pending',
          });
        }
      }
    }

    // Sort by applied date and take recent 5
    applicants.sort((a, b) {
      final aDate = (a['appliedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final bDate = (b['appliedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    setState(() {
      recentApplicants = applicants.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Analytics'),
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.red),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stat Cards
                        _buildStatCardsSection(isMobile, isTablet),
                        const SizedBox(height: 24),

                        // Applications Trend Chart
                        _buildSectionTitle('Applications Trend (Last 6 Months)'),
                        const SizedBox(height: 12),
                        _buildBarChart(isMobile),
                        const SizedBox(height: 24),

                        // Pie Chart and Categories
                        if (isMobile)
                          Column(
                            children: [
                              _buildPieChartCard(),
                              const SizedBox(height: 16),
                              _buildTopJobCategoriesCard(),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildPieChartCard()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTopJobCategoriesCard()),
                            ],
                          ),
                        const SizedBox(height: 24),

                        // Management Cards
                        if (isMobile)
                          Column(
                            children: [
                              _buildRecentJobsCard(),
                              const SizedBox(height: 16),
                              _buildRecentApplicantsCard(),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildRecentJobsCard()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildRecentApplicantsCard()),
                            ],
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildStatCardsSection(bool isMobile, bool isTablet) {
    final cards = [
      _StatCardData('Total Jobseekers', totalJobseekers.toString(), Icons.people, Colors.blue),
      _StatCardData('Total Jobs', totalJobs.toString(), Icons.work, Colors.green),
      _StatCardData('Active Jobs', activeJobs.toString(), Icons.check_circle, Colors.orange),
      _StatCardData('Total Applications', totalApplications.toString(), Icons.assignment, Colors.purple),
    ];

    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) => _buildStatCard(cards[index], isMobile),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: cards.map((card) => _buildStatCard(card, isMobile)).toList(),
    );
  }

  Widget _buildStatCard(_StatCardData data, bool isMobile) {
    return GestureDetector(
      onTap: () => _showStatDetails(data.title),
      child: Container(
        width: isMobile ? null : 180,
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
                Icon(data.icon, color: data.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.title,
                    style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.value,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: data.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap for details',
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatDetails(String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(_getStatDescription(title)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatDescription(String title) {
    switch (title) {
      case 'Total Jobseekers':
        return 'Total number of registered jobseekers in the system: $totalJobseekers';
      case 'Total Jobs':
        return 'Total number of job postings created: $totalJobs';
      case 'Active Jobs':
        return 'Jobs posted within the last 30 days: $activeJobs';
      case 'Total Applications':
        return 'Total job applications submitted by all jobseekers: $totalApplications';
      default:
        return '';
    }
  }

  Widget _buildBarChart(bool isMobile) {
    final entries = monthlyApplications.entries.toList();
    final maxY = entries.isEmpty
        ? 10.0
        : (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2).toDouble();

    return Container(
      height: isMobile ? 200 : 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: entries.isEmpty
          ? const Center(child: Text('No application data available'))
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY < 10 ? 10 : maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade800,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = entries[group.x.toInt()].key;
                      return BarTooltipItem(
                        '$month\n${rod.toY.toInt()} applications',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    setState(() {
                      if (response?.spot != null && event is FlTapUpEvent) {
                        touchedBarIndex = response!.spot!.touchedBarGroupIndex;
                      } else {
                        touchedBarIndex = -1;
                      }
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY < 10 ? 2 : (maxY / 5).ceilToDouble(),
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < entries.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              entries[value.toInt()].key,
                              style: TextStyle(fontSize: isMobile ? 10 : 12),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 36,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
                barGroups: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value.value.toDouble();
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: touchedBarIndex == index ? Colors.blue.shade800 : Colors.blueAccent,
                        width: isMobile ? 12 : 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildPieChartCard() {
    final sortedCategories = jobCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).toList();
    final total = topCategories.fold<int>(0, (sum, e) => sum + e.value);

    final colors = [Colors.purple, Colors.cyan, Colors.redAccent, Colors.orange, Colors.blue];

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jobs by Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: topCategories.isEmpty
                ? const Center(child: Text('No job data available'))
                : PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (event, response) {
                          setState(() {
                            if (response?.touchedSection != null && event is FlTapUpEvent) {
                              touchedPieIndex = response!.touchedSection!.touchedSectionIndex;
                            } else if (event is FlLongPressEnd || event is FlPanEndEvent) {
                              touchedPieIndex = -1;
                            }
                          });
                        },
                      ),
                      sections: topCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final isTouched = touchedPieIndex == index;
                        final percent = total > 0 ? (category.value / total * 100) : 0;

                        return PieChartSectionData(
                          value: category.value.toDouble(),
                          color: colors[index % colors.length],
                          title: '${percent.toStringAsFixed(1)}%',
                          titleStyle: TextStyle(
                            fontSize: isTouched ? 14 : 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          radius: isTouched ? 70 : 60,
                          badgeWidget: isTouched
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    category.key,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : null,
                          badgePositionPercentageOffset: 1.3,
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopJobCategoriesCard() {
    final sortedCategories = jobCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).toList();

    final colors = [Colors.purple, Colors.cyan, Colors.redAccent, Colors.orange, Colors.blue];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Job Categories', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (topCategories.isEmpty)
            const Text('No categories available')
          else
            ...topCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () => _showCategoryJobs(category.key),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(category.key)),
                        Text(
                          '${category.value} jobs',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showCategoryJobs(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing jobs in category: $category'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  Widget _buildRecentJobsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Job Postings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const Divider(),
          if (recentJobs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No jobs posted yet'),
            )
          else
            ...recentJobs.map((job) => _buildJobListItem(job)),
        ],
      ),
    );
  }

  Widget _buildJobListItem(Map<String, dynamic> job) {
    final postedDate = (job['postedDate'] as Timestamp?)?.toDate();
    final dateStr = postedDate != null
        ? '${postedDate.day}/${postedDate.month}/${postedDate.year}'
        : 'Unknown';

    return InkWell(
      onTap: () => _showJobDetails(job),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Icon(Icons.work, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['title'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    job['company'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${job['applicantCount']} applicants',
                    style: TextStyle(fontSize: 11, color: Colors.green.shade800),
                  ),
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showJobDetails(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: ${job['company']}'),
            const SizedBox(height: 8),
            Text('Applicants: ${job['applicantCount']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentApplicantsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Applicants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const Divider(),
          if (recentApplicants.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No applications yet'),
            )
          else
            ...recentApplicants.map((applicant) => _buildApplicantListItem(applicant)),
        ],
      ),
    );
  }

  Widget _buildApplicantListItem(Map<String, dynamic> applicant) {
    final appliedAt = (applicant['appliedAt'] as Timestamp?)?.toDate();
    final dateStr = appliedAt != null
        ? '${appliedAt.day}/${appliedAt.month}/${appliedAt.year}'
        : 'Unknown';

    final status = applicant['status'] as String;
    final statusColor = status.toLowerCase() == 'accepted'
        ? Colors.green
        : status.toLowerCase() == 'rejected'
            ? Colors.red
            : Colors.orange;

    return InkWell(
      onTap: () => _showApplicantDetails(applicant),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              child: Text(
                (applicant['name'] as String).isNotEmpty
                    ? (applicant['name'] as String)[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applicant['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    applicant['email'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicantDetails(Map<String, dynamic> applicant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(applicant['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${applicant['email']}'),
            const SizedBox(height: 8),
            Text('Status: ${applicant['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatCardData(this.title, this.value, this.icon, this.color);
}
