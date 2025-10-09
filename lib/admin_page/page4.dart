import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPageAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Analytics Page'),
        titleTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.red),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 800,
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildStatCard('Total Applicants', '12,548', '↑ 8% vs. last month'),
                    _buildStatCard('Active Accounts', '320', '↑ 5% vs. last week'),
                    _buildStatCard('Employers Registered', '1,285', '+12 new this week'),
                    _buildStatCard('Applicants Submitted', '56,732', ''),
                  ],
                ),
                SizedBox(height: 30),

                Text(
                  'Applications Trend (Number of Applications last 6 months)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                _buildBarChart(),
                SizedBox(height: 30),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPieChart()),
                    SizedBox(width: 24),
                    Expanded(child: _buildTopJobCategories()),
                  ],
                ),
                SizedBox(height: 30),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildJobManagementCard()),
                    SizedBox(width: 16),
                    Expanded(child: _buildApplicantManagementCard()),
                    SizedBox(width: 16),
                    Expanded(child: _buildEmployerManagementCard()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      width: 180,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.green[700])),
          ]
        ],
      ),
    );
  }

  // ✅ UPDATED: Bar Chart using fl_chart
  Widget _buildBarChart() {
    final barGroups = [
      _makeBarGroup(0, 72),
      _makeBarGroup(1, 76),
      _makeBarGroup(2, 78),
      _makeBarGroup(3, 75),
      _makeBarGroup(4, 80),
      _makeBarGroup(5, 90),
    ];

    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 40, // You can increase this to 50 or 60 if needed
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _bottomTitles,
                reservedSize: 36,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blueAccent,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        )
      ],
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const months = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
    final style = TextStyle(color: Colors.black, fontSize: 12);
    String text = '';
    if (value >= 0 && value < months.length) {
      text = months[value.toInt()];
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }

  Widget _buildPieChart() {
    final data = [
      {'name': 'IT & Software', 'value': 2430.0, 'color': Colors.purple},
      {'name': 'Customer Service', 'value': 1985.0, 'color': Colors.cyan},
      {'name': 'Healthcare', 'value': 1760.0, 'color': Colors.redAccent},
      {'name': 'Education', 'value': 1255.0, 'color': Colors.orange},
      {'name': 'Construction', 'value': 940.0, 'color': Colors.blue},
    ];

    final total = data.fold<double>(0.0, (sum, item) => sum + (item['value'] as double));

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: data.map((entry) {
            final percent = ((entry['value'] as double) / total * 100).toStringAsFixed(1);
            return PieChartSectionData(
              value: entry['value'] as double,
              color: entry['color'] as Color,
              title: '$percent%',
              titleStyle: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              radius: 60,
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }

  Widget _buildTopJobCategories() {
    final categories = [
      {'name': 'IT & Software', 'count': '2,430', 'color': Colors.purple},
      {'name': 'Customer Service', 'count': '1,985', 'color': Colors.cyan},
      {'name': 'Healthcare', 'count': '1,760', 'color': Colors.redAccent},
      {'name': 'Education', 'count': '1,255', 'color': Colors.orange},
      {'name': 'Construction', 'count': '940', 'color': Colors.blue},
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Job Categories (By Applicants)', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(width: 12, height: 12, color: cat['color'] as Color),
                SizedBox(width: 8),
                Expanded(child: Text(cat['name'] as String)),
                Text(cat['count'] as String),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildJobManagementCard() {
    return _buildCard(
      title: 'Job Management',
      children: [
        Text('Pending Approvals: 12', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Expiring Soon: 45'),
        SizedBox(height: 8),
        Text('Recent Jobs:', style: TextStyle(fontWeight: FontWeight.bold)),
        _bullet('1. Frontend Developer - ABC Tech Solutions\nLooking for 26 Applicants'),
        _bullet('2. Call Center Agent - Global Connect BPO\nLooking for 78 Applicants'),
        _bullet('3. Nurse - St. Mary\'s Hospital\nLooking for 15 Applicants'),
        _bullet('4. High School Teacher - Makati High School\nLooking for 21 Applicants'),
      ],
    );
  }

  Widget _buildApplicantManagementCard() {
    return _buildCard(
      title: 'Applicant Management',
      children: [
        Text('Recent Applicants:', style: TextStyle(fontWeight: FontWeight.bold)),
        _bullet('Maria Santos → Frontend Developer → Shortlisted'),
        _bullet('John Dela Cruz → Call Center Agent → Under Review'),
        _bullet('Angela Reyes → Nurse → Rejected'),
        _bullet('Mark Villanueva → High School Teacher → Interview Scheduled'),
      ],
    );
  }

  Widget _buildEmployerManagementCard() {
    return _buildCard(
      title: 'Employer Management',
      children: [
        Text('Employers Awaiting Verification: 5', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('New Employers This Week:', style: TextStyle(fontWeight: FontWeight.bold)),
        _bullet('• JRS Logistics'),
        _bullet('• BrightPath Tutorials'),
        _bullet('• TechWorks Solutions'),
        _bullet('• MedCare Hospital Group'),
        _bullet('• Axis BPO Services'),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          ...children.map((child) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: child,
          )),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 14)),
        Expanded(child: Text(text)),
      ],
    );
  }
}
