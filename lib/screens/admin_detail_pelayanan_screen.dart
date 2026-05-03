import 'package:flutter/material.dart';
import 'admin_detail_pembayaran_screen.dart';

class AdminDetailPelayananScreen extends StatefulWidget {
  final Map<String, dynamic> pasien;

  const AdminDetailPelayananScreen({super.key, required this.pasien});

  @override
  State<AdminDetailPelayananScreen> createState() =>
      _AdminDetailPelayananScreenState();
}

class _AdminDetailPelayananScreenState
    extends State<AdminDetailPelayananScreen> {

  @override
  Widget build(BuildContext context) {
    final pasien = widget.pasien;

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),

      /// ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Pelayanan Pasien",
          style: TextStyle(color: Colors.black),
        ),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ================= CARD INFO =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD8E6C3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Jenis Reservasi Pasien",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// FOTO + NAMA
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PASIEN",
                            style: TextStyle(fontSize: 10),
                          ),
                          Text(
                            pasien['namaPasien'] ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "26 TAHUN | JL. BANDUNG, KOTA MALANG, JAWA TIMUR",
                    style: TextStyle(fontSize: 11),
                  ),

                  const SizedBox(height: 16),

                  /// LAYANAN + JADWAL
                  Row(
                    children: [

                      /// LAYANAN
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1DCE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "LAYANAN",
                                style: TextStyle(fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pasien['layanan'] ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// JADWAL
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1DCE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "JADWAL",
                                style: TextStyle(fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${pasien['tanggal'] ?? '-'}, ${pasien['jam'] ?? '-'}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= VERIFIKASI =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD8E6C3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Verifikasi Layanan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// CHECKBOX
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB7E4A1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: pasien['layananSelesai'] ?? false,
                          onChanged: (val) {
                            setState(() {
                              pasien['layananSelesai'] = val!;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text("Layanan telah selesai dilakukan"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// BUTTON LANJUT PEMBAYARAN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: pasien['layananSelesai'] == true
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AdminDetailPembayaranScreen(
                                    pasien: pasien,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Lanjutkan ke Pembayaran",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}