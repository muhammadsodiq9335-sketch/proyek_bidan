import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'chat_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});
  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        title: const Text("Chat Pasien", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true, foregroundColor: _textPrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getAllUserProfiles(role: 'pasien'),
        builder: (context, snapshot) {
          final patients = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          if (isLoading) return const Center(child: CircularProgressIndicator(color: _accent));
          if (patients.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text("Belum ada pasien", style: TextStyle(color: _textSecondary)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              final name = patient['nama'] ?? 'Pasien';
              final userId = patient['id'];
              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(radius: 22, backgroundColor: const Color(0xFFFFF0F5),
                    child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 16))),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
                  subtitle: const Padding(padding: EdgeInsets.only(top: 4), child: Text("Klik untuk chat", style: TextStyle(fontSize: 12, color: _textSecondary))),
                  trailing: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.chat_rounded, size: 16, color: _accent),
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(isAdmin: true, patientName: name, receiverId: userId))),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _bottomNav(context, 2),
    );
  }

  Widget _bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex, type: BottomNavigationBarType.fixed, selectedItemColor: _accent, unselectedItemColor: const Color(0xFFB0BEC5),
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())); break;
          case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminJadwalScreen())); break;
          case 2: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen())); break;
          case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPasienScreen())); break;
          case 4: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen())); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}