import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final ScrollController _jobSeekerScrollController = ScrollController();
  final ScrollController _employerScrollController = ScrollController();
  final ScrollController _adminScrollController = ScrollController();

  @override
  void dispose() {
    _jobSeekerScrollController.dispose();
    _employerScrollController.dispose();
    _adminScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job User Management Page'),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableSection(
                  title: "Job Seeker Table",
                  headers: [
                    "ID", "Name", "Email", "Phone", "Last Applied", "Applied",
                    "Status", "Date Joined", "Last Login", "Actions"
                  ],
                  rows: List.generate(6, (index) => [
                    "ID-${index + 1}",
                    "John Doe",
                    "john.doe@email.com",
                    "+123456789",
                    "Flutter, Dart",
                    index.toString(),
                    _statusText(index),
                    "2022-10-10",
                    "2023-02-01",
                    "Actions",
                  ]),
                  actions: ["View Profile", "Delete", "Suspend"],
                  scrollController: _jobSeekerScrollController,
                ),
                const SizedBox(height: 24),
                _buildTableSection(
                  title: "Employer Table",
                  headers: [
                    "Company Name", "Contact Person", "Email", "Industry",
                    "Active Job Posts", "Verification Status", "Date Joined", "Actions"
                  ],
                  rows: List.generate(6, (index) => [
                    "Tech Corp",
                    "Alice Smith",
                    "contact@techcorp.com",
                    "Technology",
                    "5",
                    _employerStatus(index),
                    "2022-11-01",
                    "Actions"
                  ]),
                  actions: ["View Profile", "Delete", "Suspend", "Approve Verification"],
                  scrollController: _employerScrollController,
                ),
                const SizedBox(height: 24),
                _buildTableSection(
                  title: "Admin/Staff Table",
                  headers: ["EmpID", "Name", "Role", "Email", "Status", "Last Login", "Actions"],
                  rows: List.generate(6, (index) => [
                    "ADM-${index + 1}",
                    "Admin Name",
                    index == 0 ? "Super Admin" : "Moderator",
                    "admin@email.com",
                    "Active",
                    "2023-09-01",
                    "Actions"
                  ]),
                  actions: ["Add/Edit Role", "Deactivate Admin Account", "Reset Password"],
                  scrollController: _adminScrollController,
                ),
                const SizedBox(height: 32),
                Text(
                  "Summary: Views vs Applications vs Hires",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildSummaryBarChart(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _legendItem(Colors.indigo, "Views"),
                    _legendItem(Colors.green, "Applications"),
                    _legendItem(Colors.orange, "Hires"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBarChart() {
    final barGroups = [
      _makeSummaryBarGroup(0, 120, 80, 30), // Job Seekers
      _makeSummaryBarGroup(1, 90, 60, 20),  // Employers
      _makeSummaryBarGroup(2, 60, 40, 10),  // Admins
    ];

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        maxY: 150,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Job Seekers', 'Employers', 'Admins'];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    titles[value.toInt()],
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 30,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        groupsSpace: 20,
      ),
    );
  }

  BarChartGroupData _makeSummaryBarGroup(int x, double views, double applications, double hires) {
    return BarChartGroupData(
      x: x,
      barsSpace: 4,
      barRods: [
        BarChartRodData(toY: views, color: Colors.indigo, width: 10, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: applications, color: Colors.green, width: 10, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: hires, color: Colors.orange, width: 10, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTableSection({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    required List<String> actions,
    required ScrollController scrollController,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "🔍 Search",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filters"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[50],
                    foregroundColor: Colors.indigo,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              thickness: 10,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1000),
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: MaterialStateProperty.all(Colors.indigo[50]),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.indigo[100];
                        }
                        return null;
                      },
                    ),
                    border: TableBorder(horizontalInside: BorderSide(color: Colors.grey[300]!)),
                    columns: headers
                        .map((h) => DataColumn(
                      label: Text(
                        h,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ))
                        .toList(),
                    rows: rows.map((rowData) {
                      return DataRow(
                        cells: rowData.map((cell) {
                          if (cell == "Actions") {
                            return DataCell(_buildActionsDropdown(actions));
                          } else {
                            return DataCell(Text(cell));
                          }
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Displaying 1 to ${rows.length} records",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _paginationButton("First"),
                const SizedBox(width: 4),
                _paginationButton("<"),
                const SizedBox(width: 4),
                const Text("Page 1 of 1", style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                _paginationButton(">"),
                const SizedBox(width: 4),
                _paginationButton("Last"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _paginationButton(String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: Colors.indigo.shade200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(label, style: TextStyle(color: Colors.indigo[800])),
    );
  }

  String _statusText(int i) {
    const statuses = [
      "Applied",
      "ShortListed",
      "UnderReview",
      "Interviewing",
      "Interviewed",
      "Offered",
      "Hired",
      "Rejected"
    ];
    return statuses[i % statuses.length];
  }

  String _employerStatus(int i) {
    const statuses = [
      "Verified",
      "Not Verified",
      "Suspended",
      "Verified",
      "Verified",
      "Verified",
    ];
    return statuses[i % statuses.length];
  }

  Widget _buildActionsDropdown(List<String> items) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => items
          .map((action) => PopupMenuItem<String>(
        value: action,
        child: Text(action),
      ))
          .toList(),
      onSelected: (value) {
        print("Selected: $value");
      },
    );
  }
}
