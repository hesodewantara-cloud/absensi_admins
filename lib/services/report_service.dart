import 'dart:io';
import 'package:absensi_admin/models/attendance_model.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<AttendanceModel>> getAttendanceReports(
      DateTime startDate, DateTime endDate, int? roomId) async {
    var query = _supabase
        .from('attendance')
        .select()
        .gte('timestamp', startDate.toIso8601String())
        .lte('timestamp', endDate.toIso8601String());

    if (roomId != null) {
      query = query.eq('room_id', roomId);
    }

    final response = await query;
    final List<dynamic> data = response as List<dynamic>;
    return data.map((e) => AttendanceModel.fromJson(e)).toList();
  }

  Future<void> exportToCsv(List<AttendanceModel> data) async {
    final List<List<dynamic>> rows = [];
    rows.add(['User ID', 'Room ID', 'Timestamp', 'Status']);
    for (var record in data) {
      rows.add([
        record.userId,
        record.roomId,
        record.timestamp,
        record.status,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final String dir = (await getTemporaryDirectory()).path;
    final String path = '$dir/attendance_report.csv';
    final File file = File(path);
    await file.writeAsString(csv);
    OpenFile.open(path);
  }

  Future<void> exportToPdf(List<AttendanceModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: ['User ID', 'Room ID', 'Timestamp', 'Status'],
            data: data
                .map((e) => [
                      e.userId,
                      e.roomId.toString(),
                      DateFormat.yMd().add_jm().format(e.timestamp),
                      e.status,
                    ])
                .toList(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<int> getTodaysAttendanceCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final response = await _supabase
        .from('attendance')
        .count()
        .gte('timestamp', startOfDay.toIso8601String())
        .lte('timestamp', endOfDay.toIso8601String());
    return response;
  }
}