import 'package:absensi_admin/models/room_model.dart';
import 'package:absensi_admin/services/room_service.dart';
import 'package:flutter/material.dart';

class RoomEditorPage extends StatefulWidget {
  final RoomModel? room;

  const RoomEditorPage({super.key, this.room});

  @override
  State<RoomEditorPage> createState() => _RoomEditorPageState();
}

class _RoomEditorPageState extends State<RoomEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomService = RoomService();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.room != null;
    _nameController = TextEditingController(text: widget.room?.name ?? '');
    _descriptionController = TextEditingController(text: widget.room?.description ?? '');
    _latController = TextEditingController(text: widget.room?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: widget.room?.longitude.toString() ?? '');
    _radiusController = TextEditingController(text: widget.room?.radius.toString() ?? '10');
  }

  Future<void> _saveRoom() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_isEditing) {
          await _roomService.updateRoom(
            widget.room!.id,
            name: _nameController.text,
            description: _descriptionController.text,
            latitude: double.parse(_latController.text),
            longitude: double.parse(_lngController.text),
            radius: int.parse(_radiusController.text),
          );
        } else {
          await _roomService.createRoom(
            name: _nameController.text,
            description: _descriptionController.text,
            latitude: double.parse(_latController.text),
            longitude: double.parse(_lngController.text),
            radius: int.parse(_radiusController.text),
          );
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving room: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Room' : 'Add Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a latitude' : null,
              ),
              TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a longitude' : null,
              ),
              TextFormField(
                controller: _radiusController,
                decoration: const InputDecoration(labelText: 'Radius (meters)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a radius' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRoom,
                child: const Text('Save Room'),
              )
            ],
          ),
        ),
      ),
    );
  }
}