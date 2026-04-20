import 'package:flutter/material.dart';

class PusatBantuanScreen extends StatelessWidget {
  const PusatBantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Pusat Bantuan', style: TextStyle(color: Color(0xFF1B2E35), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ada yang bisa kami bantu?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2E35)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih topik yang sesuai dengan kendala Anda atau hubungi kami langsung.',
              style: TextStyle(fontSize: 13, color: Colors.black45, height: 1.4),
            ),
            const SizedBox(height: 24),
            
            _buildContactSection(),
            const SizedBox(height: 24),
            
            const Text(
              'FAQ (Tanya Jawab)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2E35)),
            ),
            const SizedBox(height: 12),
            _buildFaqItem('Cara melakukan reservasi?', 'Buka menu Reservasi, pilih jenis layanan, lalu pilih bidan dan jadwal yang tersedia.'),
            _buildFaqItem('Apakah bisa membatalkan reservasi?', 'Bisa, Anda dapat membatalkan reservasi melalui menu Riwayat Reservasi selambatnya 2 jam sebelum jadwal.'),
            _buildFaqItem('Bagaimana cara pembayaran?', 'Untuk saat ini pembayaran dilakukan secara langsung di klinik atau kepada bidan saat kunjungan rumah.'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Row(
      children: [
        Expanded(
          child: _buildContactCard(Icons.chat_bubble_outline, 'WhatsApp', 'Hubungi via Chat', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildContactCard(Icons.phone_in_talk_outlined, 'Panggilan', 'Hubungi via Telepon', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
        ),
      ],
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B2E35))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B2E35))),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
