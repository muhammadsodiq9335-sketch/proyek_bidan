import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_chat_list_screen.dart';

class AdminPasienScreen extends StatefulWidget {
  const AdminPasienScreen({super.key});

  @override
  State<AdminPasienScreen> createState() => _AdminPasienScreenState();
}

class _AdminPasienScreenState extends State<AdminPasienScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int selectedTab = 0; // 0 = Daftar Pasien, 1 = Riwayat Pembayaran

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        title: Text(
          selectedTab == 0 ? "Daftar Pasien" : "Riwayat Pembayaran",
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: const Color(0xFFE6B8BE),
        child: Column(
          children: [
            Row(
              children: [
                _tabItem("Daftar Pasien", 0),
                _tabItem("Riwayat Pembayaran", 1),
              ],
            ),
            Expanded(
              child: selectedTab == 0 ? _buildDaftarPasien() : _buildRiwayatPembayaran(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _tabItem(String title, int index) {
    final isActive = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget _buildDaftarPasien() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _supabaseService.getAllUserProfiles(role: 'pasien'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final patients = snapshot.data ?? [];
        if (patients.isEmpty) return const Center(child: Text("Belum ada pasien terdaftar"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final p = patients[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(p['nama'] ?? '-'),
                subtitle: Text(p['email'] ?? '-'),
                trailing: Text(p['role'] ?? 'Pasien', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRiwayatPembayaran() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _supabaseService.getReservasi(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reservations = (snapshot.data ?? [])
            .where((r) => r['status'] == 'Selesai' || r['status'] == 'Selesai & Pulang')
            .toList();
        
        if (reservations.isEmpty) return const Center(child: Text("Belum ada riwayat pembayaran"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final r = reservations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(r['nama_pasien'] ?? r['namaPasien'] ?? '-'),
                subtitle: Text("${r['layanan']} • ${r['tanggal']}"),
                trailing: Text(r['harga'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
        if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Pasien"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}