import 'package:absensi_admin/models/user_model.dart';
import 'package:absensi_admin/services/user_service.dart';
import 'package:flutter/material.dart';

class UserEditorPage extends StatefulWidget {
  final UserModel? user;

  const UserEditorPage({super.key, this.user});

  @override
  State<UserEditorPage> createState() => _UserEditorPageState();
}

class _UserEditorPageState extends State<UserEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String _selectedRole = 'teacher';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.user != null;
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.user?.role ?? 'teacher';
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        if (_isEditing) {
          await _userService.updateUser(
            widget.user!.id,
            name: name,
            email: email,
            role: _selectedRole,
            password: password.isNotEmpty ? password : null,
          );
        } else {
          await _userService.createUser(
            email: email,
            password: password,
            name: name,
            role: _selectedRole,
          );
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving user: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit User' : 'Add User'),
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
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password (${_isEditing ? "leave blank to keep current" : ""})'),
                obscureText: true,
                validator: (value) {
                  if (!_isEditing && (value == null || value.isEmpty)) {
                    return 'Please enter a password';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['teacher', 'admin'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text('Save User'),
              )
            ],
          ),
        ),
      ),
    );
  }
}