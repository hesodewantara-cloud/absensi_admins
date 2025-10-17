import 'package:absensi_admin/models/room_model.dart';
import 'package:absensi_admin/pages/room_editor_page.dart';
import 'package:absensi_admin/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

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
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                        rooms.first.latitude, rooms.first.longitude),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: rooms.map((room) {
                        return Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(room.latitude, room.longitude),
                          child: const FaIcon(
                            FontAwesomeIcons.locationDot,
                            color: Colors.red,
                            size: 40,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return ListTile(
                      title: Text(room.name),
                      subtitle: Text(room.description ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.penToSquare),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RoomEditorPage(room: room),
                                ),
                              );
                              _loadRooms();
                            },
                          ),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.trash),
                            onPressed: () async {
                              await _roomService.deleteRoom(room.id);
                              _loadRooms();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoomEditorPage(),
            ),
          );
          _loadRooms();
        },
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}