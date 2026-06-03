import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_jadwal_screen.dart';
import 'screens/admin_ringkasan_harian_screen.dart';
import 'screens/admin_chat_list_screen.dart';
import 'screens/admin_pasien_screen.dart';
import 'screens/admin_pengaturan_screen.dart';
import 'screens/admin_laporan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ihajzeaklcayldorglhe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImloYWp6ZWFrbGNheWxkb3JnbGhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5ODk1NTEsImV4cCI6MjA5MjU2NTU1MX0.3vxqwJvazxzwbKoa8Ti8igMblie4OHoG1ua-IBow0KM',
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
      home: const SplashScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/admin_jadwal': (context) => AdminJadwalScreen(),
        '/admin_ringkasan': (context) => const AdminRingkasanHarianScreen(),
        '/admin_chat_list': (context) => const AdminChatListScreen(),
        '/admin_pasien': (context) => const AdminPasienScreen(),
        '/admin_pembayaran': (context) => const AdminPasienScreen(), // Tambahkan ini
        '/admin_pengaturan': (context) => const AdminPengaturanScreen(),
        '/admin_laporan': (context) => const AdminLaporanScreen(),
      },
    );
  }
}
