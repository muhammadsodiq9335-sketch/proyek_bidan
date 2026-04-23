import 'package:proyek_bidan/mock_data.dart';
import 'package:flutter/material.dart';
import 'formulir_reservasi_screen.dart';

class SubLayananScreen extends StatelessWidget {
  final String kategori;
  final IconData kategoriIcon;
  final Color kategoriColor;
  final List<Map<String, dynamic>> services;
  final bool isHomeCare;

  const SubLayananScreen({
    super.key,
    required this.kategori,
    required this.kategoriIcon,
    required this.kategoriColor,
    required this.services,
    this.isHomeCare = false,
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
        title: Text(
          kategori,
          style: const TextStyle(
            color: Color(0xFF1B2E35),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF1B2E35)),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header banner kategori
          _buildKategoriBanner(),
          // Daftar layanan
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(context, services[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: kategoriColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kategoriColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kategoriColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(kategoriIcon, color: kategoriColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kategori,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kategoriColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${services.length} layanan tersedia • ${isHomeCare ? 'Home Care' : 'Klinik'}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkAndNavigate(BuildContext context, Map<String, dynamic> service) {
    // Check if there is an active reservation
    final activeReservation = MockDatabase.userReservations.any((r) =>
        r['status'] == 'Menunggu Persetujuan' ||
        r['status'] == 'Menunggu Konfirmasi');

    if (activeReservation) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Reservasi Aktif'),
            ],
          ),
          content: const Text(
              'Bunda masih memiliki reservasi yang sedang diproses. Silakan tunggu konfirmasi atau batalkan reservasi sebelumnya untuk membuat yang baru.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ok', style: TextStyle(color: Color(0xFF00897B))),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulirReservasiScreen(
          layanan: service['title'],
          isHomeCare: isHomeCare,
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final bool isChatAdmin = service['price'] == 'Chat Admin';

    return GestureDetector(
      onTap: () => _checkAndNavigate(context, service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Ikon layanan
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kategoriColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(service['icon'] as IconData,
                  color: kategoriColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Nama & deskripsi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['title'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service['desc'],
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Harga + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isChatAdmin
                        ? const Color(0xFFE3F2FD)
                        : const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    service['price'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isChatAdmin
                          ? const Color(0xFF1976D2)
                          : const Color(0xFF00897B),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right,
                    color: Colors.black26, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
