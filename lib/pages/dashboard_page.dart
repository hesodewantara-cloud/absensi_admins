import 'package:absensi_admin/services/dashboard_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, int>> _statsFuture;
  late Future<Map<String, double>> _attendanceChartFuture;
  late Future<Map<String, double>> _sickLeaveChartFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _statsFuture = _dashboardService.getDashboardStats();
      _attendanceChartFuture = _dashboardService.getAttendanceChartData();
      _sickLeaveChartFuture = _dashboardService.getSickLeaveChartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Future.wait([_statsFuture, _attendanceChartFuture, _sickLeaveChartFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final stats = snapshot.data![0] as Map<String, int>;
          final attendanceData = snapshot.data![1] as Map<String, double>;
          final sickLeaveData = snapshot.data![2] as Map<String, double>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatsGrid(stats),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPieChartCard('Attendance Status', attendanceData),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBarChartCard('Sick Leave Status', sickLeaveData),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          icon: FontAwesomeIcons.users,
          label: 'Total Users',
          value: stats['totalUsers'].toString(),
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: FontAwesomeIcons.doorOpen,
          label: 'Total Rooms',
          value: stats['totalRooms'].toString(),
          color: Colors.green,
        ),
        _buildStatCard(
          icon: FontAwesomeIcons.solidCalendarCheck,
          label: 'Today\'s Attendance',
          value: stats['todaysAttendance'].toString(),
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: FontAwesomeIcons.solidFileMedical,
          label: 'Pending Leaves',
          value: stats['pendingLeaves'].toString(),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, size: 32, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(String title, Map<String, double> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${entry.key}\n${entry.value.toInt()}',
                      color: Colors.primaries[data.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                      radius: 80,
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(String title, Map<String, double> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: data.entries.map((entry) {
                    return BarChartGroupData(
                      x: data.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.primaries[data.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                     leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(data.keys.toList()[value.toInt()]);
                        },
                        reservedSize: 38,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}