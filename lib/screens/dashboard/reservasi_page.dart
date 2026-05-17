import 'package:flutter/material.dart';
import '../layanan_screen.dart';
import '../riwayat_reservasi_screen.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';

class ReservasiPage extends StatelessWidget {
  const ReservasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();

    return SafeArea(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabaseService.getReservasi(userId: AuthService.currentUserProfile?.id),
        builder: (context, snapshot) {
          final reservations = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),

                // Pilih Jenis Layanan
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pilih Jenis Layanan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2E35),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Pilih cara bidan merawat Bunda",
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                      const SizedBox(height: 16),
                      _buildLayananCard(
                        context: context,
                        icon: Icons.home_work_outlined,
                        title: "Home Care",
                        subtitle:
                            "Bidan datang ke rumah Bunda. Tersedia layanan pijat, konseling, perawatan bayi & lebih.",
                        badgeText: "8 Layanan",
                        gradientColors: const [Color(0xFF26A69A), Color(0xFF80CBC4)],
                        badgeColor: const Color(0xFF00897B),
                        tab: 1,
                      ),
                      const SizedBox(height: 14),
                      _buildLayananCard(
                        context: context,
                        icon: Icons.local_hospital_outlined,
                        title: "Datang ke Klinik",
                        subtitle:
                            "Kunjungi klinik kami. Tersedia periksa hamil, imunisasi, KB, persalinan & lebih.",
                        badgeText: "11 Layanan",
                        gradientColors: const [Color(0xFFF48FB1), Color(0xFFF8BBD0)],
                        badgeColor: const Color(0xFFF06292),
                        tab: 0,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Riwayat Reservasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Riwayat Reservasi",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2E35),
                            ),
                          ),
                          if (reservations.isNotEmpty)
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const RiwayatReservasiScreen()),
                              ),
                              child: const Text(
                                "Lihat Semua →",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00897B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (reservations.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 28, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 44, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              const Text(
                                "Belum ada reservasi",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Pilih layanan di atas untuk mulai",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black26),
                              ),
                            ],
                          ),
                        )
                      else
                        ...reservations
                            .take(3)
                            .map((r) => _buildReservasiItem(r))
                            .toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buat Reservasi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E35),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Halo, ${AuthService.currentUserProfile?.nama.split(' ')[0] ?? 'Bunda'}! Mau layanan apa hari ini?",
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_outlined,
                color: Color(0xFF00897B), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required List<Color> gradientColors,
    required Color badgeColor,
    required int tab,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LayananScreen(initialTab: tab),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$badgeText tersedia →",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservasiItem(Map<String, dynamic> r) {
    final String status = r['status'] ?? '-';
    Color statusColor;
    Color statusBg;

    if (status == 'Menunggu Persetujuan') {
      statusColor = const Color(0xFFF9A825);
      statusBg = const Color(0xFFFFF8E1);
    } else if (status == 'Ditolak' || status == 'Dibatalkan') {
      statusColor = Colors.red;
      statusBg = const Color(0xFFFFEBEE);
    } else if (status == 'Selesai') {
      statusColor = Colors.blue;
      statusBg = const Color(0xFFE3F2FD);
    } else {
      // Dikonfirmasi
      statusColor = const Color(0xFF00897B);
      statusBg = const Color(0xFFE0F2F1);
    }

    final bool isHomeCare = r['is_home_care'] == true || r['isHomeCare'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isHomeCare
                  ? Icons.home_work_outlined
                  : Icons.local_hospital_outlined,
              color: const Color(0xFF00897B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['layanan'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E35),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${r['tanggal'] ?? '-'} • ${r['jam'] ?? '-'}",
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
