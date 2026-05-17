import 'package:flutter/material.dart';
import 'patient_view_rekam_medis_screen.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class RiwayatReservasiScreen extends StatefulWidget {
  const RiwayatReservasiScreen({super.key});

  @override
  State<RiwayatReservasiScreen> createState() => _RiwayatReservasiScreenState();
}

class _RiwayatReservasiScreenState extends State<RiwayatReservasiScreen> {
  final supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Riwayat Reservasi',
            style: TextStyle(
                color: Color(0xFF1B2E35),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF1B2E35)),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabaseService.getReservasi(
            userId: AuthService.currentUserProfile?.id),
        builder: (context, snapshot) {
          final reservations = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reservations.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              return _buildReservationCard(res);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.black12),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat reservasi',
            style: TextStyle(
                fontSize: 16, color: Colors.black38, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Layanan yang Anda pesan akan muncul di sini',
            style: TextStyle(fontSize: 12, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> res) {
    final String status = res['status'] ?? '-';
    Color statusBg;
    Color statusTextColor;

    if (status == 'Menunggu Persetujuan') {
      statusBg = const Color(0xFFFFF8E1);
      statusTextColor = const Color(0xFFF9A825);
    } else if (status == 'Ditolak' || status == 'Dibatalkan') {
      statusBg = const Color(0xFFFFEBEE);
      statusTextColor = Colors.red;
    } else if (status == 'Bidan Diganti') {
      statusBg = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFE65100);
    } else if (status == 'Selesai') {
      statusBg = const Color(0xFFE3F2FD);
      statusTextColor = Colors.blue;
    } else {
      // Dikonfirmasi
      statusBg = const Color(0xFFE0F2F1);
      statusTextColor = const Color(0xFF00796B);
    }

    final bool isHomeCare =
        res['is_home_care'] == true || res['isHomeCare'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor),
                ),
              ),
              Text(
                res['tanggal'] ?? '-',
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            res['layanan'] ?? '-',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E35)),
          ),
          const SizedBox(height: 4),
          const Divider(height: 20),
          if (status == 'Ditolak' && res['alasan_ditolak'] != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Alasan: ${res['alasan_ditolak']}',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.black38),
              const SizedBox(width: 4),
              Text(res['jam'] ?? '-',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 16),
              Icon(
                isHomeCare ? Icons.home_outlined : Icons.local_hospital_outlined,
                size: 14,
                color: Colors.black38,
              ),
              const SizedBox(width: 4),
              Text(
                isHomeCare ? 'Kunjungan Rumah' : 'Klinik',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          if (status == 'Dikonfirmasi' || status == 'Selesai') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientViewRekamMedisScreen(
                            reservasiId: res['id'],
                            namaLayanan: res['layanan'] ?? '-',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.medical_information_outlined, size: 18),
                    label: const Text('Buku KIA Digital', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00897B),
                      side: const BorderSide(color: Color(0xFF00897B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (status == 'Selesai') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: supabaseService.getReviewByReservation(res['id']),
                      builder: (context, revSnapshot) {
                        final review = revSnapshot.data;
                        if (review == null) {
                          return ElevatedButton.icon(
                            onPressed: () => _showReviewDialog(res),
                            icon: const Icon(Icons.star_rounded, size: 18, color: Colors.white),
                            label: const Text('Beri Ulasan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9A825),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          );
                        }
                        // Jika sudah ada review
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < (review['rating'] ?? 0) ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: Colors.amber, size: 12,
                                )),
                              ),
                              if (review['admin_reply'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  "Balasan Admin: ${review['admin_reply']}",
                                  style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Color(0xFFC2185B), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ] else if (status == 'Menunggu Persetujuan') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Batalkan Reservasi?'),
                      content: const Text('Apakah Bunda yakin ingin membatalkan reservasi ini?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Kembali')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await supabaseService.updateStatusReservasi(res['id'].toString(), 'Dibatalkan');
                      if (mounted) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reservasi berhasil dibatalkan')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal membatalkan: $e')),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Batalkan Reservasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
          if (status == 'Bidan Diganti') ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              "Bidan reservasi Anda telah diubah oleh Admin. Apakah Bunda setuju untuk melanjutkan?",
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await SupabaseService()
                            .updateStatusReservasi(res['id'], 'Dibatalkan');
                        setState(() {});
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Batalkan', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await SupabaseService()
                            .updateStatusReservasi(res['id'], 'Menunggu Persetujuan');
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Perubahan disetujui. Menunggu konfirmasi ulang dari Admin.')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child:
                        const Text('Lanjutkan', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showReviewDialog(Map<String, dynamic> res) {
    int rating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Beri Ulasan Pelayanan', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bagaimana pelayanan untuk ${res['layanan']}?', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setDialogState(() => rating = index + 1),
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: const Color(0xFFF9A825),
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis kesan Bunda di sini...',
                  hintStyle: const TextStyle(fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'reservasi_id': res['id'],
                  'user_id': AuthService.currentUserProfile?.id,
                  'nama_pasien': AuthService.currentUserProfile?.nama,
                  'rating': rating,
                  'review_text': reviewController.text.trim(),
                };
                await supabaseService.tambahReview(data);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih atas ulasan Bunda! ❤️'), backgroundColor: Color(0xFF00897B)));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Kirim Ulasan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
