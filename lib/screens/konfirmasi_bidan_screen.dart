import 'package:flutter/material.dart';
import '../mock_data.dart';

class KonfirmasiBidanScreen extends StatelessWidget {
  final String layanan;
  final String bidan;
  final String jam;
  final String tanggal;
  final bool isHomeCare;

  const KonfirmasiBidanScreen({
    super.key,
    required this.layanan,
    required this.bidan,
    required this.jam,
    required this.tanggal,
    required this.isHomeCare,
  });

  String _endTime(String jam) {
    final parts = jam.split(':');
    final hour = int.parse(parts[0]) + 1;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

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
          'Konfirmasi Bidan',
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
          children: [
            const SizedBox(height: 16),

            // Success card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time,
                        color: Color(0xFF00897B), size: 44),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Menunggu Persetujuan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Permintaan Anda telah kami terima.\nMohon tunggu admin/bidan menyetujui\njadwal Anda.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black45, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Text(
                      'STATUS: MENUNGGU PERSETUJUAN',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB48A00)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Layanan chip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.medical_services_outlined,
                              color: Color(0xFF00897B), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LAYANAN',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              layanan,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2E35),
                              ),
                            ),
                            Text(
                              isHomeCare ? 'Kunjungan Rumah • 60 Menit' : 'Datang ke Klinik • 60 Menit',
                              style: const TextStyle(fontSize: 11, color: Colors.black45),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Janji Temu
            Container(
              width: double.infinity,
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
                    'Rincian Janji Temu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildRincianRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'WAKTU KUNJUNGAN',
                    value: '$tanggal\n$jam - ${_endTime(jam)} WIB',
                  ),
                  const Divider(height: 20, color: Color(0xFFF5F5F5)),
                  _buildRincianRow(
                    icon: Icons.location_on_outlined,
                    label: 'LOKASI ANDA',
                    value: MockDatabase.currentUser?.alamat ?? 'Alamat belum diatur',
                  ),
                  const Divider(height: 20, color: Color(0xFFF5F5F5)),
                  _buildRincianRow(
                    icon: Icons.payments_outlined,
                    label: 'ESTIMASI BIAYA',
                    value: 'Rp 175.000',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline, size: 15, color: Color(0xFFF9A825)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Estimasi biaya hanya perkiraan. Pembayaran dilakukan setelah bidan mengkonfirmasi pesanan. Kami akan mengirimkan notifikasi segera.',
                            style: TextStyle(fontSize: 10, color: Color(0xFF795548), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Butuh bantuan
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Butuh bantuan segera? ',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Icon(Icons.headset_mic_outlined, color: Color(0xFF00897B), size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Hubungi Customer Care',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Batalkan Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black54,
                  side: const BorderSide(color: Colors.black26),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Batalkan Reservasi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRincianRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black45,
                letterSpacing: 0.5,
              ),
            ),
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
