import 'package:absensi_admin/models/attendance_model.dart';
import 'package:absensi_admin/models/room_model.dart';
import 'package:absensi_admin/services/report_service.dart';
import 'package:absensi_admin/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportService _reportService = ReportService();
  final RoomService _roomService = RoomService();
  late Future<List<AttendanceModel>> _attendanceFuture;
  late Future<List<RoomModel>> _roomsFuture;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  int? _selectedRoomId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _attendanceFuture =
          _reportService.getAttendanceReports(_startDate, _endDate, _selectedRoomId);
      _roomsFuture = _roomService.getRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<AttendanceModel>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No attendance records found.'));
                }

                final attendanceRecords = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('User ID')),
                      DataColumn(label: Text('Room ID')),
                      DataColumn(label: Text('Timestamp')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: attendanceRecords.map((record) {
                      return DataRow(cells: [
                        DataCell(Text(record.userId)),
                        DataCell(Text(record.roomId.toString())),
                        DataCell(Text(DateFormat.yMd().add_jm().format(record.timestamp))),
                        DataCell(Text(record.status ?? '')),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange:
                          DateTimeRange(start: _startDate, end: _endDate),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                        _loadData();
                      });
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.calendarDays),
                  label: Text(
                      '${DateFormat.yMd().format(_startDate)} - ${DateFormat.yMd().format(_endDate)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FutureBuilder<List<RoomModel>>(
                  future: _roomsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final rooms = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      initialValue: _selectedRoomId,
                      hint: const Text('All Rooms'),
                      items: rooms.map((room) {
                        return DropdownMenuItem<int>(
                          value: room.id,
                          child: Text(room.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoomId = value;
                          _loadData();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final data = await _attendanceFuture;
                  await _reportService.exportToCsv(data);
                },
                icon: const FaIcon(FontAwesomeIcons.fileCsv),
                label: const Text('Export to CSV'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final data = await _attendanceFuture;
                  await _reportService.exportToPdf(data);
                },
                icon: const FaIcon(FontAwesomeIcons.filePdf),
                label: const Text('Export to PDF'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}