import 'package:absensi_admin/config/supabase_config.dart';
import 'package:absensi_admin/pages/dashboard_page.dart';
import 'package:absensi_admin/pages/login_page.dart';
import 'package:absensi_admin/pages/splash_page.dart';
import 'package:absensi_admin/pages/profile_page.dart';
import 'package:absensi_admin/pages/attendance_report_page.dart';
import 'package:absensi_admin/pages/rooms_page.dart';
import 'package:absensi_admin/pages/users_page.dart';
import 'package:absensi_admin/services/auth_service.dart';
import 'package:absensi_admin/widgets/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:absensi_admin/pages/sick_leaves_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Absensi Admin',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const MainLayout(child: DashboardPage()),
          '/attendance': (context) => const MainLayout(child: AttendanceReportPage()),
          '/rooms': (context) => const MainLayout(child: RoomsPage()),
          '/users': (context) => const MainLayout(child: UsersPage()),
          '/leaves': (context) => const MainLayout(child: SickLeavesPage()),
          '/profile': (context) => const MainLayout(child: ProfilePage()),
        },
      ),
    );
  }
}