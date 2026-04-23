import 'package:flutter/material.dart';

// OPTIONAL (kalau sudah ada di project kamu)
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';

class PengaturanNotifikasiScreen extends StatefulWidget {
  const PengaturanNotifikasiScreen({super.key});

  @override
  State<PengaturanNotifikasiScreen> createState() =>
      _PengaturanNotifikasiScreenState();
}

class _PengaturanNotifikasiScreenState
    extends State<PengaturanNotifikasiScreen> {
  bool isNotifOn = true;
  double volume = 0.6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),

      /// ===== APPBAR =====
      appBar: AppBar(
  backgroundColor: const Color(0xFFDDE6CF),
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminPengaturanScreen(),
        ),
      );
    },
  ),
  title: const Text(
    "Pengaturan Notifikasi",
    style: TextStyle(color: Colors.black),
  ),
),

      /// ===== BODY =====
      body: Container(
        color: const Color(0xFFE6B8BE), // pink
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Pengaturan Notifikasi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Atur notifikasi aplikasi",
                style: TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 16),

              /// ===== SWITCH =====
              _card(
                child: Row(
                  children: [
                    _iconBox(Icons.notifications),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Nyalakan Notifikasi",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text(
                            "Aktifkan notifikasi langsung (real-time)",
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value: isNotifOn,
                      onChanged: (value) {
                        setState(() => isNotifOn = value);
                      },
                      activeColor: Colors.green,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// ===== VOLUME =====
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _iconBox(Icons.volume_up),
                        const SizedBox(width: 12),
                        const Text("Volume",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Atur kerasnya suara notifikasi",
                      style: TextStyle(fontSize: 11),
                    ),

                    Slider(
                      value: volume,
                      onChanged: (value) {
                        setState(() => volume = value);
                      },
                      activeColor: Colors.black,
                    ),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("MIN", style: TextStyle(fontSize: 10)),
                        Text("MAX", style: TextStyle(fontSize: 10)),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// ===== RINGTONE =====
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pilihan Nada Dering",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Pilih nada notifikasi untuk aktivitas kerja",
                      style: TextStyle(fontSize: 11),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 10),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mora Song",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                "Stabil dan profesional (Default)",
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.check_circle, color: Colors.black)
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: const [
                        Icon(Icons.add_circle_outline),
                        SizedBox(width: 6),
                        Text("Tambah Nada Dering"),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// ===== BOTTOM NAV =====
      bottomNavigationBar: _bottomNav(context, 3),
    );
  }

  /// ===== CARD STYLE =====
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E8C8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  /// ===== ICON BOX =====
  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18),
    );
  }

  /// ===== BOTTOM NAV =====
  Widget _bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF1B5E20),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminJadwalScreen(),
              ),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminPengaturanScreen(),
              ),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Pasien"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}