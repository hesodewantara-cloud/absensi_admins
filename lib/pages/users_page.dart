import 'package:absensi_admin/models/user_model.dart';
import 'package:absensi_admin/pages/user_editor_page.dart';
import 'package:absensi_admin/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _userService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name ?? 'No Name'),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.penToSquare), // ganti edit
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserEditorPage(user: user),
                          ),
                        );
                        if (!mounted) return; // ✅ cek mounted sebelum pakai context
                        _loadUsers();
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.trash),
                      onPressed: () async {
                        await _userService.deleteUser(user.id);
                        if (!mounted) return; // ✅ cek mounted
                        _loadUsers();
                      },
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserEditorPage(),
            ),
          );
          if (!mounted) return; // ✅ cek mounted
          _loadUsers();
        },
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    );
  }
}
