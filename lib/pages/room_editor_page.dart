import 'package:absensi_admin/models/room_model.dart';
import 'package:absensi_admin/services/room_service.dart';
import 'package:absensi_admin/widgets/custom_button.dart';
import 'package:absensi_admin/widgets/custom_input.dart';
import 'package:flutter/material.dart';

class RoomEditorPage extends StatefulWidget {
  final RoomModel? room;

  const RoomEditorPage({super.key, this.room});

  @override
  State<RoomEditorPage> createState() => _RoomEditorPageState();
}

class _RoomEditorPageState extends State<RoomEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _nameController.text = widget.room!.name;
      _descriptionController.text = widget.room!.description ?? '';
      _latitudeController.text = widget.room!.latitude.toString();
      _longitudeController.text = widget.room!.longitude.toString();
      _radiusController.text = widget.room!.radiusMeters.toString();
    }
  }

  Future<void> _saveRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final roomService = RoomService();
      final room = RoomModel(
        id: widget.room?.id ?? 0,
        name: _nameController.text,
        description: _descriptionController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        radiusMeters: int.parse(_radiusController.text),
      );

      try {
        if (widget.room == null) {
          await roomService.addRoom(room);
        } else {
          await roomService.updateRoom(room);
        }
        if (!mounted) return;
  Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room == null ? 'Add Room' : 'Edit Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(
                controller: _nameController,
                hintText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _descriptionController,
                hintText: 'Description',
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _latitudeController,
                hintText: 'Latitude',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a latitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _longitudeController,
                hintText: 'Longitude',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a longitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _radiusController,
                hintText: 'Radius (meters)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a radius';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _saveRoom,
                text: 'Save',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}