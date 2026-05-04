import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_jadwal_screen.dart';
import 'screens/admin_ringkasan_harian_screen.dart';
import 'screens/admin_chat_list_screen.dart';
import 'screens/admin_pasien_screen.dart';
import 'screens/admin_pengaturan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ihajzeaklcayldorglhe.supabase.co',
    anonKey: 'sb_publishable_PJrJNYM6Nvb_bmvfACOnTA_DL1ZYExs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MORA Reservasi Bidan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFCE4EC)),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const LoginScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/admin_jadwal': (context) => AdminJadwalScreen(),
        '/admin_ringkasan': (context) => const AdminRingkasanHarianScreen(),
        '/admin_chat_list': (context) => const AdminChatListScreen(),
        '/admin_pasien': (context) => const AdminPasienScreen(),
        '/admin_pengaturan': (context) => const AdminPengaturanScreen(),
      },
    );
  }
}
