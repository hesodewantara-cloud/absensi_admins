import 'package:absensi_admin/services/report_service.dart';
import 'package:absensi_admin/services/room_service.dart';
import 'package:absensi_admin/services/user_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final UserService _userService = UserService();
  final RoomService _roomService = RoomService();
  final ReportService _reportService = ReportService();

  late Future<int> _totalUsers;
  late Future<int> _totalRooms;
  late Future<int> _todaysAttendance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _totalUsers = _userService.getUsers().then((value) => value.length);
      _totalRooms = _roomService.getRooms().then((value) => value.length);
      _todaysAttendance = _reportService.getTodaysAttendanceCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Total Users', _totalUsers),
                  _buildStatCard('Total Rooms', _totalRooms),
                  _buildStatCard('Today\'s Attendance', _todaysAttendance),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Weekly Attendance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20,
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: 8, color: Colors.indigo)
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 10, color: Colors.indigo)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 14, color: Colors.indigo)
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(toY: 15, color: Colors.indigo)
                      ]),
                      BarChartGroupData(x: 4, barRods: [
                        BarChartRodData(toY: 13, color: Colors.indigo)
                      ]),
                      BarChartGroupData(x: 5, barRods: [
                        BarChartRodData(toY: 10, color: Colors.indigo)
                      ]),
                      BarChartGroupData(x: 6, barRods: [
                        BarChartRodData(toY: 17, color: Colors.indigo)
                      ]),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            );
                            String text;
                            switch (value.toInt()) {
                              case 0:
                                text = 'M';
                                break;
                              case 1:
                                text = 'T';
                                break;
                              case 2:
                                text = 'W';
                                break;
                              case 3:
                                text = 'T';
                                break;
                              case 4:
                                text = 'F';
                                break;
                              case 5:
                                text = 'S';
                                break;
                              case 6:
                                text = 'S';
                                break;
                              default:
                                text = '';
                                break;
                            }
                            return Text(text, style: style);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, Future<int> future) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error', style: TextStyle(fontSize: 24));
                } else {
                  return Text(
                    snapshot.data.toString(),
                    style: const TextStyle(fontSize: 24),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}