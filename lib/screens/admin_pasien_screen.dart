import 'package:flutter/material.dart';

// SESUAIKAN DENGAN PROJECT KAMU
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
  int selectedDateIndex = 2;
  DateTime startDate = DateTime.now();

  final List<Map<String, String>> pasienList = [
    {"nama": "Maryam EW", "tgl": "12 Jan 2000", "alamat": "Jl. Kapten"},
    {"nama": "Fuji Furaba", "tgl": "24 Mei 1997", "alamat": "Jl. Sukuni"},
    {"nama": "Mayya MT", "tgl": "17 Juni 1996", "alamat": "Jl. Saguni"},
  ];

  final List<String> hari = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),

      /// ===== APPBAR =====
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        title: const Text("Pasien", style: TextStyle(color: Colors.black)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 12, backgroundColor: Colors.grey),
          )
        ],
      ),

      /// ===== BODY =====
      body: Container(
        color: const Color(0xFFE6B8BE),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// ===== SEARCH =====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Cari pasien berdasarkan nama atau ID",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ===== CEK TANGGAL =====
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE99AA3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    /// HEADER + BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16),
                            SizedBox(width: 6),
                            Text("Cek Tanggal"),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  startDate = startDate.subtract(
                                    const Duration(days: 1),
                                  );
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  startDate = startDate.add(
                                    const Duration(days: 1),
                                  );
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// TANGGAL DINAMIS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        DateTime date =
                            startDate.add(Duration(days: index));

                        String dayName = hari[date.weekday % 7];
                        String dateNumber = date.day.toString();

                        bool isSelected = selectedDateIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedDateIndex = index);
                          },
                          child: Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green.shade200
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(dayName,
                                    style: const TextStyle(fontSize: 10)),
                                Text(
                                  dateNumber,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ===== RIWAYAT PASIEN =====
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "RIWAYAT REGISTRASI PASIEN",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("NAMA", style: TextStyle(fontSize: 10)),
                        Text("TGL LAHIR", style: TextStyle(fontSize: 10)),
                        Text("ALAMAT", style: TextStyle(fontSize: 10)),
                      ],
                    ),

                    const Divider(),

                    ...pasienList.map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p["nama"]!),
                            Text(p["tgl"]!),
                            Text(p["alamat"]!),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("1/2", style: TextStyle(fontSize: 10)),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Selanjutnya"),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),

      /// ===== BOTTOM NAV =====
      bottomNavigationBar: _bottomNav(context),
    );
  }

  /// ===== BOTTOM NAV =====
  Widget _bottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 3,
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
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          }
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