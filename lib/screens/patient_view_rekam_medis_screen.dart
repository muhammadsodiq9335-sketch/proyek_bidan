import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:intl/intl.dart';

class PatientViewRekamMedisScreen extends StatefulWidget {
  final String reservasiId;
  final String namaLayanan;
  const PatientViewRekamMedisScreen({super.key, required this.reservasiId, required this.namaLayanan});

  @override
  State<PatientViewRekamMedisScreen> createState() => _PatientViewRekamMedisScreenState();
}

class _PatientViewRekamMedisScreenState extends State<PatientViewRekamMedisScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? _rekamMedis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _supabaseService.getRekamMedisByReservasi(widget.reservasiId);
      setState(() {
        _rekamMedis = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF00897B); // Teal untuk kesan medis pasien
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      appBar: AppBar(
        title: const Text('Detail Pemeriksaan Medis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: accentColor))
        : _rekamMedis == null
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(accentColor),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Detail Pemeriksaan Medis (SOAP)'),
                  const SizedBox(height: 12),
                  _buildNoteCard(
                    'Subjective (S) - Keluhan & Kondisi Pasien',
                    _rekamMedis!['subjective'] ?? '-',
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                  _buildNoteCard(
                    'Objective (O) - Hasil Pemeriksaan Fisik & Vital Sign',
                    _rekamMedis!['objective'] ?? '-',
                    icon: Icons.visibility_outlined,
                  ),
                  _buildNoteCard(
                    'Assessment (A) - Diagnosa & Analisa Medis',
                    _rekamMedis!['assessment'] ?? '-',
                    icon: Icons.analytics_outlined,
                  ),
                  _buildNoteCard(
                    'Plan (P) - Rencana Tindakan & Rekomendasi',
                    _rekamMedis!['plan'] ?? '-',
                    isSpecial: true,
                    icon: Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_information_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Rekam medis belum tersedia', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const Text('Silakan hubungi bidan Anda', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent, accent.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REKAM MEDIS PASIEN', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.namaLayanan, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              const Text('Terverifikasi oleh Bidan', style: TextStyle(color: Colors.white, fontSize: 11)),
              const Spacer(),
              Text(_formatDate(_rekamMedis!['created_at']), style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF37474F)));
  }

  Widget _buildInfoGrid(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00897B)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B2E35))),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String title, String content, {bool isSpecial = false, IconData? icon}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSpecial ? const Color(0xFFE0F2F1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSpecial ? const Color(0xFF00897B).withOpacity(0.3) : Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: isSpecial ? const Color(0xFF00796B) : const Color(0xFF00897B)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: isSpecial ? const Color(0xFF00796B) : Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(content, style: const TextStyle(fontSize: 13, color: const Color(0xFF1B2E35), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic iso) {
    if (iso == null) return '-';
    final dt = DateTime.tryParse(iso.toString()) ?? DateTime.now();
    return DateFormat('dd MMM yyyy').format(dt);
  }
}
