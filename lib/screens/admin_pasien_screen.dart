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
  int selectedDateIndex = 2;
  DateTime startDate = DateTime.now();

  final List<String> hari = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

  List<Map<String, String>> _processPasienList(List<Map<String, dynamic>> reservations) {
    final Map<String, Map<String, String>> uniquePatients = {};
    for (var res in reservations) {
      final email = res['email_pasien'] ?? res['emailPasien'] ?? '';
      if (!uniquePatients.containsKey(email)) {
        uniquePatients[email] = {
          "nama": res['nama_pasien'] ?? res['namaPasien'] ?? '-',
          "tgl": res['tanggal'] ?? '-',
          "alamat": res['alamat'] ?? '-', // Jika ada di tabel reservasi
        };
      }
    }
    return uniquePatients.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE6CF),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.getReservasi(),
        builder: (context, snapshot) {
          final rawData = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final filteredList = _processPasienList(rawData);

          return Container(
            color: const Color(0xFFE6B8BE),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE99AA3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
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
                                      startDate = startDate.subtract(const Duration(days: 1));
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    setState(() {
                                      startDate = startDate.add(const Duration(days: 1));
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            DateTime date = startDate.add(Duration(days: index));
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
                                  color: isSelected ? const Color(0xFFB7E4A1) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(hari[date.weekday % 7], style: const TextStyle(fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(date.day.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          child: Text("RIWAYAT PEMBAYARAN PASIEN", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("NAMA PASIEN", style: TextStyle(fontSize: 10)),
                            Text("TANGGAL", style: TextStyle(fontSize: 10)),
                            Text("ALAMAT", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        const Divider(),
                        if (isLoading)
                          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                        if (!isLoading && filteredList.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada data pasien"))),
                        ...filteredList.map((p) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey.shade400,
                                  child: Text(p["nama"]!.isNotEmpty ? p["nama"]!.substring(0, 1) : "?", style: const TextStyle(fontSize: 10)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(flex: 3, child: Text(p["nama"]!, style: const TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text(p["tgl"]!)),
                                Expanded(flex: 3, child: Text(p["alamat"]!, overflow: TextOverflow.ellipsis)),
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
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66BB6A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
          );
        },
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