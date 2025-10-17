import 'package:absensi_admin/models/user_model.dart';
import 'package:absensi_admin/services/user_service.dart';
import 'package:absensi_admin/widgets/custom_button.dart';
import 'package:absensi_admin/widgets/custom_input.dart';
import 'package:flutter/material.dart';

class UserEditorPage extends StatefulWidget {
  final UserModel? user;

  const UserEditorPage({super.key, this.user});

  @override
  State<UserEditorPage> createState() => _UserEditorPageState();
}

class _UserEditorPageState extends State<UserEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name ?? '';
      _usernameController.text = widget.user!.username ?? '';
      _emailController.text = widget.user!.email;
      _selectedRole = widget.user!.role;
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userService = UserService();
      final user = UserModel(
        id: widget.user?.id ?? '',
        username: _usernameController.text,
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
      );

      try {
        if (widget.user == null) {
          await userService.addUser(user, _passwordController.text);
        } else {
          await userService.updateUser(user);
        }
       if (!mounted) return; // ✅ cek mounted sebelum pakai context
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
        title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(
                controller: _usernameController,
                hintText: 'Username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                controller: _emailController,
                hintText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.user == null)
                CustomInput(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (widget.user == null &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter a password';
                    }
                    if (widget.user == null && value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                hint: const Text('Role'),
                items: ['teacher', 'admin'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a role' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _saveUser,
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