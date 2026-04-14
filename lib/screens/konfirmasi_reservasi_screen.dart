import 'package:flutter/material.dart';
import 'konfirmasi_bidan_screen.dart';

class KonfirmasiReservasiScreen extends StatelessWidget {
  final String nama;
  final String nik;
  final String tglLahir;
  final String alamat;
  final String layanan;
  final String jam;

  const KonfirmasiReservasiScreen({
    super.key,
    required this.nama,
    required this.nik,
    required this.tglLahir,
    required this.alamat,
    required this.layanan,
    required this.jam,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Header title
            const Text(
              'Ringkasan Data Pasien',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E35),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mohon periksa kembali data Anda sebelum mengirim',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
            const SizedBox(height: 16),

            // Data Pasien Card
            _buildDataCard(context),
            const SizedBox(height: 16),

            // Detail Layanan Card
            _buildLayananCard(),
            const SizedBox(height: 16),

            // Info note
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

            // Kirim Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KonfirmasiBidanScreen(
                        layanan: layanan,
                        jam: jam,
                      ),
                    ),
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

  Widget _buildDataCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          _buildDataRow('NAMA LENGKAP', nama, isFirst: true),
          _buildDataRow('NIK', nik),
          _buildDataRow('TEMPAT, TGL LAHIR', tglLahir),
          _buildDataRow('ALAMAT', alamat, isLast: true),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value,
      {bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFF5F5F5), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2E35),
              ),
            ),
          ),
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
          _buildDetailRow(Icons.calendar_month_outlined, 'Layanan Dipilih', layanan),
          const Divider(height: 16, color: Color(0xFFF5F5F5)),
          _buildDetailRow(Icons.access_time_outlined, 'Jadwal Kunjungan',
              'Senin, 24 Mei 2026\nPukul $jam - ${_endTime(jam)} WIB'),
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

  String _endTime(String jam) {
    final parts = jam.split(':');
    final hour = int.parse(parts[0]) + 1;
    return '${hour.toString().padLeft(2, '0')}:00';
  }
}
