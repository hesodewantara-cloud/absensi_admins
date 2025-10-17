import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SickLeavesPage extends StatefulWidget {
  const SickLeavesPage({super.key});

  @override
  State<SickLeavesPage> createState() => _SickLeavesPageState();
}

class _SickLeavesPageState extends State<SickLeavesPage> {
  final _stream = Supabase.instance.client.from('sick_leaves').stream(primaryKey: ['id']).order('submitted_at', ascending: false);

  Future<void> _updateStatus(int id, String status) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    try {
      await Supabase.instance.client.from('sick_leaves').update({
        'status': status,
        'reviewed_by': currentUser.id,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave request has been $status.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String> _getUserName(String userId) async {
    final response = await Supabase.instance.client.from('users').select('name').eq('id', userId).single();
    return response['name'] ?? 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin & Verifikasi'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sick leave requests found.'));
          }

          final leaves = snapshot.data!;

          return ListView.builder(
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              final leave = leaves[index];
              final status = leave['status'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _getUserName(leave['user_id']),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Loading user...', style: TextStyle(fontWeight: FontWeight.bold));
                          }
                          return Text(userSnapshot.data ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
                        },
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildInfoRow('Tanggal:', '${DateFormat('dd MMM yyyy').format(DateTime.parse(leave['start_date']))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(leave['end_date']))}'),
                      _buildInfoRow('Alasan:', leave['reason']),
                      _buildInfoRow('Status:', status, statusColor: _getStatusColor(status)),
                      if (leave['attachment_url'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: InkWell(
                            onTap: () {
                              // In a real app, you would open the URL.
                              // For this example, we just print it.
                              print('Attachment URL: ${leave['attachment_url']}');
                            },
                            child: const Text('View Attachment', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (status == 'Menunggu')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _updateStatus(leave['id'], 'Ditolak'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Tolak'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateStatus(leave['id'], 'Disetujui'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Setujui'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}