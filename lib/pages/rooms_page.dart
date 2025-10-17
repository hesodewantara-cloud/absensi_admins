import 'package:absensi_admin/models/room_model.dart';
import 'package:absensi_admin/pages/room_editor_page.dart';
import 'package:absensi_admin/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final RoomService _roomService = RoomService();
  late Future<List<RoomModel>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    setState(() {
      _roomsFuture = _roomService.getRooms();
    });
  }

  Future<void> _confirmDelete(RoomModel room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${room.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _roomService.deleteRoom(room.id);
        _loadRooms();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting room: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
      ),
      body: FutureBuilder<List<RoomModel>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rooms found.'));
          }

          final rooms = snapshot.data!;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: const FaIcon(FontAwesomeIcons.doorOpen),
                title: Text(room.name),
                subtitle: Text(room.description ?? 'No description'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.penToSquare),
                      onPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomEditorPage(room: room),
                          ),
                        );
                        if (result == true) {
                          _loadRooms();
                        }
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.trash),
                      onPressed: () => _confirmDelete(room),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const RoomEditorPage(),
            ),
          );
          if (result == true) {
            _loadRooms();
          }
        },
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}