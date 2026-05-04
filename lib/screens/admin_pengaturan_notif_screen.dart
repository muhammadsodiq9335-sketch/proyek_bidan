import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';

class PengaturanNotifikasiScreen extends StatefulWidget {
  const PengaturanNotifikasiScreen({super.key});
  @override
  State<PengaturanNotifikasiScreen> createState() => _PengaturanNotifikasiScreenState();
}

class _PengaturanNotifikasiScreenState extends State<PengaturanNotifikasiScreen> {
  bool isNotifOn = true;
  double volume = 0.6;

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
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()))),
        title: const Text("Pengaturan Notifikasi", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Pengaturan Notifikasi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textPrimary)),
          const SizedBox(height: 4),
          const Text("Atur notifikasi aplikasi", style: TextStyle(fontSize: 12, color: _textSecondary)),
          const SizedBox(height: 16),
          // Switch card
          _card(child: Row(children: [
            _iconBox(Icons.notifications_outlined),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text("Nyalakan Notifikasi", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
              SizedBox(height: 2),
              Text("Aktifkan notifikasi langsung (real-time)", style: TextStyle(fontSize: 11, color: _textSecondary)),
            ])),
            Switch(value: isNotifOn, onChanged: (v) => setState(() => isNotifOn = v), activeColor: _accent),
          ])),
          const SizedBox(height: 12),
          // Volume card
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [_iconBox(Icons.volume_up_outlined), const SizedBox(width: 12), const Text("Volume", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary))]),
            const SizedBox(height: 4),
            const Text("Atur kerasnya suara notifikasi", style: TextStyle(fontSize: 11, color: _textSecondary)),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(activeTrackColor: _accent, thumbColor: _accent, inactiveTrackColor: const Color(0xFFFFF0F5)),
              child: Slider(value: volume, onChanged: (v) => setState(() => volume = v)),
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("MIN", style: TextStyle(fontSize: 10, color: _textSecondary)),
              Text("MAX", style: TextStyle(fontSize: 10, color: _textSecondary)),
            ]),
          ])),
          const SizedBox(height: 12),
          // Ringtone card
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Pilihan Nada Dering", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
            const SizedBox(height: 4),
            const Text("Pilih nada notifikasi untuk aktivitas kerja", style: TextStyle(fontSize: 11, color: _textSecondary)),
            const SizedBox(height: 10),
            Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.music_note_rounded, size: 18, color: _accent)),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Mora Song", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
                Text("Stabil dan profesional (Default)", style: TextStyle(fontSize: 11, color: _textSecondary)),
              ])),
              const Icon(Icons.check_circle_rounded, color: _accent),
            ]),
            const SizedBox(height: 12),
            Row(children: const [Icon(Icons.add_circle_outline_rounded, color: _accent), SizedBox(width: 6), Text("Tambah Nada Dering", style: TextStyle(color: _accent, fontWeight: FontWeight.w600))]),
          ])),
        ]),
      ),
      bottomNavigationBar: _bottomNav(context, 3),
    );
  }

  Widget _card({required Widget child}) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow), child: child);
  }

  Widget _iconBox(IconData icon) {
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: _accent));
  }

  Widget _bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex, selectedItemColor: _accent, unselectedItemColor: const Color(0xFFB0BEC5), type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen())); break;
          case 1: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminJadwalScreen())); break;
          case 3: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen())); break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}