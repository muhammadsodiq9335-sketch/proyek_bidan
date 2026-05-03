import 'package:flutter/material.dart';
import '../mock_data.dart';

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

  final List<String> hari = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

  List<Map<String, String>> get pasienList {
    final Map<String, Map<String, String>> uniquePatients = {};
    for (var res in MockDatabase.userReservations) {
      final email = res['emailPasien'] as String? ?? '';
      if (!uniquePatients.containsKey(email)) {
        uniquePatients[email] = {
          "nama": res['namaPasien'] ?? '-',
          "tgl": "-",
          "alamat": "-",
        };

        if (MockDatabase.userProfiles.containsKey(email)) {
          uniquePatients[email]!["tgl"] =
              MockDatabase.userProfiles[email]!.tglLahir;
          uniquePatients[email]!["alamat"] =
              MockDatabase.userProfiles[email]!.alamat;
        }
      }
    }
    return uniquePatients.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),

      /// ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6CF),
        elevation: 0,
        title: const Text(
          "Riwayat Pembayaran Pasien",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 14, backgroundColor: Colors.grey),
          )
        ],
      ),

      /// ================= BODY =================
      body: Container(
        color: const Color(0xFFE6B8BE),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// ================= SEARCH =================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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

              /// ================= DATE PICKER =================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE99AA3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [

                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16),
                            SizedBox(width: 6),
                            Text("Cek Tanggal",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  startDate =
                                      startDate.subtract(const Duration(days: 1));
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  startDate =
                                      startDate.add(const Duration(days: 1));
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// DATE LIST
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        DateTime date =
                            startDate.add(Duration(days: index));

                        bool isSelected = selectedDateIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedDateIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFB7E4A1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  hari[date.weekday % 7],
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  date.day.toString(),
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

              /// ================= TABLE =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1DCE5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "RIWAYAT PEMBAYARAN PASIEN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// HEADER TABLE
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("NAMA PASIEN", style: TextStyle(fontSize: 10)),
                        Text("TANGGAL", style: TextStyle(fontSize: 10)),
                        Text("ALAMAT", style: TextStyle(fontSize: 10)),
                      ],
                    ),

                    const Divider(),

                    /// DATA LIST
                    ...pasienList.map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [

                            /// AVATAR
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey.shade400,
                              child: Text(
                                p["nama"]!.substring(0, 1),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// NAMA
                            Expanded(
                              flex: 3,
                              child: Text(
                                p["nama"]!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            /// TGL
                            Expanded(
                              flex: 2,
                              child: Text(p["tgl"]!),
                            ),

                            /// ALAMAT
                            Expanded(
                              flex: 3,
                              child: Text(
                                p["alamat"]!,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    /// PAGINATION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("1/2", style: TextStyle(fontSize: 10)),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF66BB6A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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

      bottomNavigationBar: _bottomNav(context),
    );
  }

  /// ================= BOTTOM NAV =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: Colors.grey,

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        }
        if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        }
        if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => AdminChatListScreen()));
        }
        if (index == 4) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
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