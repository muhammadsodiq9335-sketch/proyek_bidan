import 'package:flutter/material.dart';
import '../mock_data.dart';

class RiwayatReservasiScreen extends StatelessWidget {
  const RiwayatReservasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservations = MockDatabase.userReservations;

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Riwayat Reservasi', style: TextStyle(color: Color(0xFF1B2E35), fontWeight: FontWeight.bold, fontSize: 18)),
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
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: reservations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final res = reservations[index];
                return _buildReservationCard(res);
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
            style: TextStyle(fontSize: 16, color: Colors.black38, fontWeight: FontWeight.w600),
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
    final bool isWaiting = status == 'Menunggu Persetujuan';
    final bool isConfirmed = status == 'Dikonfirmasi';
    final Color statusBg = isWaiting
        ? const Color(0xFFFFF8E1)
        : isConfirmed
            ? const Color(0xFFE0F2F1)
            : const Color(0xFFF5F5F5);
    final Color statusTextColor = isWaiting
        ? const Color(0xFFF9A825)
        : isConfirmed
            ? const Color(0xFF00796B)
            : const Color(0xFF9E9E9E);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusTextColor),
                ),
              ),
              Text(
                res['tanggal'],
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            res['layanan'],
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2E35)),
          ),
          const SizedBox(height: 4),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.black38),
              const SizedBox(width: 4),
              Text(res['jam'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 16),
              Icon(
                res['isHomeCare'] ? Icons.home_outlined : Icons.local_hospital_outlined,
                size: 14,
                color: Colors.black38,
              ),
              const SizedBox(width: 4),
              Text(
                res['isHomeCare'] ? 'Kunjungan Rumah' : 'Klinik',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
