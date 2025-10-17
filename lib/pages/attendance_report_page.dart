import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  late Future<List<Map<String, dynamic>>> _attendanceFuture;
  DateTime? _selectedDate;
  int? _selectedRoomId;
  List<Map<String, dynamic>> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _attendanceFuture = _fetchAttendance();
  }

  Future<void> _loadRooms() async {
    final response = await Supabase.instance.client.from('rooms').select();
    setState(() {
      _rooms = (response as List).map((item) => item as Map<String, dynamic>).toList();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAttendance() async {
    var query = Supabase.instance.client.from('attendance').select('*, users(name), rooms(name)');

    if (_selectedDate != null) {
      final start = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      query = query.gte('timestamp', '$start 00:00:00').lte('timestamp', '$start 23:59:59');
    }
    if (_selectedRoomId != null) {
      query = query.eq('room_id', _selectedRoomId!);
    }

    final response = await query;
    return (response as List).map((item) => item as Map<String, dynamic>).toList();
  }

  void _onFilterChanged() {
    setState(() {
      _attendanceFuture = _fetchAttendance();
    });
  }

  Future<void> _exportToCsv(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return;

    List<List<dynamic>> rows = [];
    // Add headers
    rows.add(['User', 'Room', 'Timestamp', 'Status']);
    // Add data
    for (var item in data) {
      rows.add([
        item['users']['name'],
        item['rooms']['name'],
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(item['timestamp'])),
        item['status'],
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/attendance_report.csv';
    final file = File(path);
    await file.writeAsString(csv);

    OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No attendance records found.'));
                }

                final attendanceList = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Room')),
                        DataColumn(label: Text('Timestamp')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Photo')),
                      ],
                      rows: attendanceList.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item['users']?['name'] ?? 'N/A')),
                          DataCell(Text(item['rooms']?['name'] ?? 'N/A')),
                          DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(item['timestamp'])))),
                          DataCell(Text(item['status'])),
                          DataCell(
                            item['photo_url'] != null
                                ? Image.network(item['photo_url'], width: 50, height: 50, fit: BoxFit.cover)
                                : const Text('No Photo'),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => _exportToCsv(snapshot.data!),
              child: const Icon(Icons.download),
              tooltip: 'Export to CSV',
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedRoomId,
              decoration: const InputDecoration(labelText: 'Room', border: OutlineInputBorder()),
              items: _rooms.map((room) {
                return DropdownMenuItem<int>(
                  value: room['id'],
                  child: Text(room['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoomId = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ),
              controller: TextEditingController(
                text: _selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              ),
              readOnly: true,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _onFilterChanged,
            child: const Text('Filter'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDate = null;
                _selectedRoomId = null;
              });
              _onFilterChanged();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}