import 'package:flutter/material.dart';
import 'konfirmasi_bidan_screen.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class KonfirmasiReservasiScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedServices;
  final String layananNames;
  final String jam;
  final DateTime tanggal;
  final bool isHomeCare;
  final int hargaTotal;
  final String keluhan;
  final String bidanId;
  final String bidanNama;

  const KonfirmasiReservasiScreen({
    super.key,
    required this.selectedServices,
    required this.layananNames,
    required this.jam,
    required this.tanggal,
    required this.isHomeCare,
    required this.hargaTotal,
    this.keluhan = '',
    this.bidanId = '',
    this.bidanNama = '',
  });

  String _getFormattedDate() {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}";
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
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
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

            // ===== PROFIL PASIEN =====
            if (AuthService.currentUserProfile != null) ...[
              _buildProfilCard(),
              const SizedBox(height: 16),
            ],

            // ===== LAYANAN & JADWAL =====
            _buildLayananCard(),
            const SizedBox(height: 16),

            // ===== BIDAN DIPILIH =====
            if (bidanId.isNotEmpty && bidanNama.isNotEmpty) ...[
              _buildBidanCard(),
              const SizedBox(height: 16),
            ],

            // ===== KELUHAN =====
            if (keluhan.isNotEmpty) ...[
              _buildKeluhanCard(),
              const SizedBox(height: 16),
            ],


            // ===== INFO =====
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
                      'Dengan menekan tombol konfirmasi, Anda menyetujui jadwal dan ketentuan reservasi yang berlaku di Taman Ibu.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF00695C),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== TOMBOL KIRIM =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final supabaseService = SupabaseService();
                  final namaPasien =
                      AuthService.currentUserProfile?.nama ?? 'Pasien';
                  final emailPasien =
                      AuthService.currentUserProfile?.email ?? '';

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final Map<String, dynamic> payload = {
                      'user_id': AuthService.currentUserProfile?.id,
                      'layanan': layananNames,
                      'layanan_id': selectedServices.isNotEmpty
                          ? selectedServices.first['id']
                          : null,
                      'jam': jam,
                      'tanggal':
                          "${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}",
                      'is_home_care': isHomeCare,
                      'status': 'Menunggu Persetujuan',
                      'nama_pasien': namaPasien,
                      'email_pasien': emailPasien,
                      'harga': hargaTotal,
                    };

                    // Tambahkan keluhan jika diisi
                    if (keluhan.isNotEmpty) {
                      payload['keluhan'] = keluhan;
                    }

                    // Tambahkan bidan_id jika dipilih
                    if (bidanId.isNotEmpty) {
                      payload['bidan_id'] = bidanId;
                    }

                    final newReservasi = await supabaseService.tambahReservasi(payload);
                    final reservasiId = newReservasi['id'].toString();

                    // Tambahkan Notifikasi untuk Pasien
                    await supabaseService.tambahNotifikasi(
                      userId: AuthService.currentUserProfile?.id ?? '',
                      title: 'Reservasi Terkirim',
                      message: 'Reservasi Bunda untuk $layananNames telah berhasil dikirim dan sedang menunggu persetujuan.',
                      icon: 'check_circle',
                      screen: 'riwayat',
                    );

                    Navigator.pop(context); // Tutup loading

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KonfirmasiBidanScreen(
                          layanan: layananNames,
                          jam: jam,
                          tanggal: _getFormattedDate(),
                          isHomeCare: isHomeCare,
                          harga: "Rp $hargaTotal",
                          reservasiId: reservasiId,
                        ),
                      ),
                      (route) => route.isFirst,
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Gagal membuat reservasi: $e'),
                          backgroundColor: Colors.redAccent),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Kirim Reservasi',
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
    return _buildCard(
      title: 'Profil Pasien',
      children: [
        _buildDetailRow(Icons.person_outline, 'Nama Lengkap',
            AuthService.currentUserProfile!.nama),
        const Divider(height: 16, color: Color(0xFFF5F5F5)),
        _buildDetailRow(Icons.cake_outlined, 'Tanggal Lahir',
            AuthService.currentUserProfile!.tglLahir),
        const Divider(height: 16, color: Color(0xFFF5F5F5)),
        _buildDetailRow(Icons.location_on_outlined, 'Alamat',
            AuthService.currentUserProfile!.alamat),
      ],
    );
  }

  Widget _buildLayananCard() {
    return _buildCard(
      title: 'Detail Layanan & Jadwal',
      children: [
        _buildDetailRow(
            Icons.medical_services_outlined, 'Layanan Dipilih', layananNames),
        const Divider(height: 16, color: Color(0xFFF5F5F5)),
        _buildDetailRow(
          Icons.access_time_outlined,
          'Jadwal Kunjungan',
          '${_getFormattedDate()}\nPukul $jam WIB',
        ),
        const Divider(height: 16, color: Color(0xFFF5F5F5)),
        _buildDetailRow(
          Icons.home_work_outlined,
          'Jenis Kunjungan',
          isHomeCare ? 'Home Care (Kunjungan Rumah)' : 'Datang ke Klinik',
        ),
        const Divider(height: 16, color: Color(0xFFF5F5F5)),
        _buildDetailRow(
          Icons.payments_outlined,
          'Total Harga',
          'Rp $hargaTotal',
          subtitle: 'Pembayaran dapat dilakukan melalui Transfer, Cash, dan QRIS',
        ),
      ],
    );
  }

  Widget _buildBidanCard() {
    return _buildCard(
      title: 'Bidan yang Dipilih',
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE0F2F1),
              child: const Icon(Icons.person,
                  color: Color(0xFF00897B), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bidanNama,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Bidan Terpilih',
                    style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Dipilih',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeluhanCard() {
    return _buildCard(
      title: 'Keluhan Awal Pasien',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBE7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC5E1A5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.format_quote_rounded,
                      color: Color(0xFF8BC34A), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Catatan Keluhan',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF558B2F)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                keluhan,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1B2E35),
                    height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.lock_outline, size: 12, color: Color(0xFF78909C)),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Keluhan ini hanya dapat dilihat oleh admin dan bidan yang bertugas.',
                style:
                    TextStyle(fontSize: 11, color: Color(0xFF78909C), height: 1.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentBadge(String text, {bool isClickable = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isClickable ? const Color(0xFF004D40) : const Color(0xFFC5E1A5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isClickable ? const Color(0xFF004D40) : const Color(0xFF33691E)),
          ),
          if (isClickable) ...[
            const SizedBox(width: 4),
            const Icon(Icons.qr_code_2, size: 12, color: Color(0xFF004D40)),
          ],
        ],
      ),
    );
  }

  void _showQRISDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Scan QRIS untuk Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/qris.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
                        SizedBox(height: 8),
                        Text('Gambar QRIS belum tersedia', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Taman Ibu Bidan Annisa',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text(
              'Pastikan nominal sesuai dengan total reservasi',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String title, required List<Widget> children}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {String? subtitle}) {
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.black45)),
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
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF00897B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
