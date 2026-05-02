import 'package:flutter/material.dart';
import 'konfirmasi_bidan_screen.dart';
import '../mock_data.dart';

class KonfirmasiReservasiScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedServices;
  final String layananNames;
  final String jam;
  final String tanggal;
  final bool isHomeCare;
  final String hargaTotal;

  const KonfirmasiReservasiScreen({
    super.key,
    required this.selectedServices,
    required this.layananNames,
    required this.jam,
    required this.tanggal,
    required this.isHomeCare,
    required this.hargaTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konfirmasi Reservasi',
          style: TextStyle(
            color: Color(0xFF1B2E35),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF1B2E35)),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Ringkasan Reservasi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E35),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mohon periksa kembali pilihan Anda sebelum mengirim',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            const SizedBox(height: 16),

            if (MockDatabase.currentUser != null) ...[
              _buildProfilCard(),
              const SizedBox(height: 16),
            ],

            _buildLayananCard(),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFF00897B), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dengan menekan tombol konfirmasi, Anda menyetujui jadwal dan ketentuan reservasi yang berlaku di Klinik Bidan Mandiri Salsah Amalia.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF00695C), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final namaPasien = MockDatabase.currentUser?.nama ?? 'Pasien';
                  final emailPasien = MockDatabase.currentUser?.email ?? '';

                  MockDatabase.userReservations.insert(0, {
                    'layanan': layananNames,
                    'jam': jam,
                    'tanggal': tanggal,
                    'isHomeCare': isHomeCare,
                    'status': 'Menunggu Persetujuan',
                    'namaPasien': namaPasien,
                    'emailPasien': emailPasien,
                    'harga': hargaTotal,
                    'timestamp': DateTime.now(),
                  });

                  MockDatabase.notifications.insert(0, {
                    'title': 'Reservasi Terkirim',
                    'message': 'Reservasi ${''} Anda sedang menunggu persetujuan admin.',
                    'timestamp': DateTime.now(),
                  });

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KonfirmasiBidanScreen(
                        layanan: layananNames,
                        jam: jam,
                        tanggal: tanggal,
                        isHomeCare: isHomeCare,
                        harga: hargaTotal,
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAED581),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Kirim',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Pasien',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
            ),
          ),
          const SizedBox(height: 14),
          _buildDetailRow(Icons.person_outline, 'Nama Lengkap', MockDatabase.currentUser!.nama),
          const Divider(height: 16, color: Color(0xFFF5F5F5)),
          _buildDetailRow(Icons.cake_outlined, 'Tanggal Lahir', MockDatabase.currentUser!.tglLahir),
          const Divider(height: 16, color: Color(0xFFF5F5F5)),
          _buildDetailRow(Icons.location_on_outlined, 'Alamat', MockDatabase.currentUser!.alamat),
        ],
      ),
    );
  }

  Widget _buildLayananCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Layanan & Jadwal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
            ),
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            Icons.medical_services_outlined,
            'Layanan Dipilih',
            layananNames,
          ),
          const Divider(height: 16, color: Color(0xFFF5F5F5)),
          _buildDetailRow(
            Icons.access_time_outlined,
            'Jadwal Kunjungan',
            '$tanggal\nPukul $jam WIB',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00897B), size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E35),
                height: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
