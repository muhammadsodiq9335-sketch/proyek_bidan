import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_pasien_screen.dart';
import '../mock_data.dart';

class AdminJadwalDetailReservasiScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const AdminJadwalDetailReservasiScreen({
    super.key,
    required this.data,
  });

  @override
  State<AdminJadwalDetailReservasiScreen> createState() =>
      _AdminJadwalDetailReservasiScreenState();
}

class _AdminJadwalDetailReservasiScreenState
    extends State<AdminJadwalDetailReservasiScreen> {

  int selectedBidan = -1;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFEECAD0),

      appBar: AppBar(
        title: const Text("Detail Reservasi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),

      bottomNavigationBar: _bottomNav(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ================= PROFILE =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE99AA3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    data['namaPasien'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("26 Tahun"),
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "Jl. Bandung, Kota Malang, Jawa Timur",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text("Umum"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ================= INFO =================
            _infoCard(Icons.calendar_today, "TANGGAL",
                _displayDate(data['tanggal'])),
            const SizedBox(height: 10),
            _infoCard(Icons.access_time, "WAKTU", data['jam'] ?? '-'),
            const SizedBox(height: 10),
            _infoCard(Icons.note, "JENIS RESERVASI",
                data['layanan'] ?? '-'),

            const SizedBox(height: 20),

            /// ================= PILIH BIDAN =================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pilih Bidan Untuk Pelayanan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            /// 🔥 DINAMIS DARI MOCK DATABASE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                MockDatabase.bidanList.length,
                (index) {
                  final bidan = MockDatabase.bidanList[index];
                  return _bidanItem(bidan.nama, index);
                },
              ),
            ),

            const SizedBox(height: 10),

            /// 🔥 TAMPILKAN YANG DIPILIH
            if (selectedBidan != -1)
              Text(
                "Dipilih: ${MockDatabase.bidanList[selectedBidan].nama}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),

            /// ================= BUTTON =================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedBidan == -1
                        ? null
                        : () {
                            widget.data['status'] = 'Dikonfirmasi';

                            /// 🔥 SIMPAN BIDAN KE RESERVASI
                            widget.data['bidan'] =
                                MockDatabase.bidanList[selectedBidan].nama;

                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("✔ Terima"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.data['status'] = 'Ditolak';
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("✖ Tolak"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ================= BIDAN ITEM =================
  Widget _bidanItem(String name, int index) {
    final isSelected = selectedBidan == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBidan = index;
        });
      },
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    isSelected ? Colors.green : Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),

              if (isSelected)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check,
                        size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= INFO CARD =================
  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF5D8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10)),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= DATE =================
  String _displayDate(String iso) {
    final date = DateTime.parse(iso);

    const bulan = [
      'JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI',
      'JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER'
    ];

    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  /// ================= NAV =================
  Widget _bottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        /// 🔥 STYLE BARU
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: const Color(0xFFB0BEC5),

        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.5,
        ),

        /// 🔥 NAVIGASI (TETAP PUNYA KAMU)
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
          }
          if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
          }
          if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
          }
          if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
          }
        },

        /// 🔥 ICON (SAMA, TAPI SUDAH IKUT WARNA)
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Jadwal",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Pasien",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Pengaturan",
          ),
        ],
      ),
    );
  }
}