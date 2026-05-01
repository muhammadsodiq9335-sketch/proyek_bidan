import 'package:flutter/material.dart';

import '../mock_data.dart';

class AdminDetailPelayananScreen extends StatefulWidget {
  final Map<String, dynamic> pasien;

  const AdminDetailPelayananScreen({super.key, required this.pasien});

  @override
  State<AdminDetailPelayananScreen> createState() =>
      _AdminDetailPelayananScreenState();
}

class _AdminDetailPelayananScreenState
    extends State<AdminDetailPelayananScreen> {

  void _updateStatus() {
    if (widget.pasien['layananSelesai'] == true &&
        widget.pasien['pembayaranSelesai'] == true) {
      widget.pasien['statusPelayanan'] = 'Selesai';
    } else {
      widget.pasien['statusPelayanan'] = 'Diproses';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pasien = widget.pasien;

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),

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
                            pasien['namaPasien'],
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
                                pasien['layanan'],
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
                                "${pasien['tanggal']}, ${pasien['jam']}",
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

            /// ================= CHECKLIST =================
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
                    "Verifikasi Checklist",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// LAYANAN
                  _checkItem(
                    title: "Layanan telah selesai dilakukan",
                    value: pasien['layananSelesai'] ?? false,
                    onChanged: (val) {
                      setState(() {
                        pasien['layananSelesai'] = val;
                        _updateStatus();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  /// PEMBAYARAN
                  _checkItem(
                    title: "Pembayaran telah dikonfirmasi",
                    value: pasien['pembayaranSelesai'] ?? false,
                    onChanged: (val) {
                      setState(() {
                        pasien['pembayaranSelesai'] = val;
                        _updateStatus();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= STATUS =================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Status: ${pasien['statusPelayanan']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ================= CHECK ITEM =================
  Widget _checkItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB7E4A1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (val) => onChanged(val!),
          ),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }
}