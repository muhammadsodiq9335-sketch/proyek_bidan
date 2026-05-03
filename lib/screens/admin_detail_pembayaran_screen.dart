import 'package:flutter/material.dart';

/// IMPORT SCREEN NAVBAR (PASTIKAN ADA)
import 'admin_dashboard_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';

class AdminDetailPembayaranScreen extends StatefulWidget {
  final Map<String, dynamic> pasien;

  const AdminDetailPembayaranScreen({super.key, required this.pasien});

  @override
  State<AdminDetailPembayaranScreen> createState() =>
      _AdminDetailPembayaranScreenState();
}

class _AdminDetailPembayaranScreenState
    extends State<AdminDetailPembayaranScreen> {

  int subtotal = 85000;
  int tambahan = 0;

  int get total => subtotal + tambahan;

  @override
  Widget build(BuildContext context) {
    final pasien = widget.pasien;

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),

      /// ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        title: const Text(
          "Detail Pembayaran",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ================= INFO PASIEN =================
            _cardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("INFORMASI PASIEN",
                      style: TextStyle(fontSize: 10)),

                  const SizedBox(height: 6),

                  Text(
                    pasien['namaPasien'] ?? '-',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1DCE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text("LAYANAN (harga pelayanan)",
                            style: TextStyle(fontSize: 10)),
                        const SizedBox(height: 4),
                        Text(
                          "${pasien['layanan']} \nRp $subtotal",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= LAYANAN TAMBAHAN =================
            _cardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Layanan Tambahan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _showTambahDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text("Tambah"),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  _layananItem("Pijat nifas", "±45 Menit", 200000),
                  const SizedBox(height: 10),
                  _layananItem("Pijat laktasi", "±45 Menit", 250000),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= RINGKASAN =================
            _cardContainer(
              color: const Color(0xFFD1DCE5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Ringkasan Tagihan",
                      style: TextStyle(fontWeight: FontWeight.bold)),

                  const SizedBox(height: 12),

                  _rowHarga("Subtotal Reservasi Awal", subtotal),
                  const SizedBox(height: 6),
                  _rowHarga("Total Layanan Tambahan", tambahan),

                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Tagihan",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        "Rp $total",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pembayaran berhasil")),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text("Pembayaran Selesai Dilakukan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: _bottomNav(context),
    );
  }

  /// ================= WIDGET =================

  Widget _cardContainer({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFD8E6C3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _layananItem(String title, String durasi, int harga) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.spa, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(durasi, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Text("Rp $harga")
        ],
      ),
    );
  }

  Widget _rowHarga(String title, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text("Rp $value"),
      ],
    );
  }

  /// ================= DIALOG TAMBAH =================
  void _showTambahDialog() {
    setState(() {
      tambahan += 200000; // contoh nambah manual dulu
    });
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
        if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => AdminChatListScreen()));
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