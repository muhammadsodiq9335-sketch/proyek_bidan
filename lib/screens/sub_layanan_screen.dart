import 'package:flutter/material.dart';
import 'formulir_reservasi_screen.dart';
import '../mock_data.dart';

class SubLayananScreen extends StatefulWidget {
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
  State<SubLayananScreen> createState() => _SubLayananScreenState();
}

class _SubLayananScreenState extends State<SubLayananScreen> {
  final List<Map<String, dynamic>> _selectedServices = [];

  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      final exists = _selectedServices.any((s) => s['title'] == service['title']);
      if (exists) {
        _selectedServices.removeWhere((s) => s['title'] == service['title']);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  void _checkAndNavigate() {
    if (_selectedServices.isEmpty) return;

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
          selectedServices: _selectedServices,
          isHomeCare: widget.isHomeCare,
        ),
      ),
    );
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
        title: Text(
          widget.kategori,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: widget.services.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(widget.services[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedServices.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _checkAndNavigate,
              backgroundColor: const Color(0xFF00897B),
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Lanjutkan Reservasi (${_selectedServices.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildKategoriBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: widget.kategoriColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.kategoriColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.kategoriColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.kategoriIcon, color: widget.kategoriColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kategori,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.kategoriColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pilih satu atau lebih layanan • ${widget.isHomeCare ? 'Home Care' : 'Klinik'}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final bool isSelected = _selectedServices.any((s) => s['title'] == service['title']);

    return GestureDetector(
      onTap: () => _toggleService(service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF00897B) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Checkbox indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00897B) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF00897B) : Colors.black26,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            // Ikon layanan
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.kategoriColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(service['icon'] as IconData,
                  color: widget.kategoriColor, size: 22),
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
            // Harga
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                service['price'],
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
