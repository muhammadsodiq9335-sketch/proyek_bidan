import 'package:flutter/material.dart';
import 'konfirmasi_reservasi_screen.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import 'pengaturan_akun_screen.dart';

class FormulirReservasiScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedServices;
  final bool isHomeCare;

  const FormulirReservasiScreen({
    super.key,
    required this.selectedServices,
    this.isHomeCare = false,
  });

  @override
  State<FormulirReservasiScreen> createState() =>
      _FormulirReservasiScreenState();
}

class _FormulirReservasiScreenState extends State<FormulirReservasiScreen> {
  String? _selectedJam;
  DateTime? _selectedDate;
  String? _selectedBidanId;
  String? _selectedBidanNama;

  final _dateController = TextEditingController();
  final _keluhanController = TextEditingController();

  final List<String> jamList = [
    '08:00', '09:00', '10:00', '11:00', '13:00', '14:00'
  ];

  List<Map<String, dynamic>> _existingReservations = [];
  List<Map<String, dynamic>> _bidanList = [];
  bool _isLoadingBidan = true;

  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadBidan();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _keluhanController.dispose();
    super.dispose();
  }

  Future<void> _loadBidan() async {
    try {
      final list = await _supabaseService.getBidan();
      if (mounted) {
        setState(() {
          _bidanList = list;
          _isLoadingBidan = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBidan = false);
    }
  }

  Future<void> _fetchExistingReservations(DateTime date) async {
    final isoDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final data = await _supabaseService.getReservasi();
    if (mounted) {
      setState(() {
        _existingReservations =
            data.where((res) => res['tanggal'] == isoDate).toList();
      });
    }
  }

  int _calculateTotalHargaRaw() {
    int total = 0;
    for (var service in widget.selectedServices) {
      final priceRaw = service['harga'];
      if (priceRaw is int) {
        total += priceRaw;
      } else if (priceRaw != null) {
        String numericStr =
            priceRaw.toString().replaceAll(RegExp(r'[^0-9]'), '');
        if (numericStr.isNotEmpty) total += int.parse(numericStr);
      }
    }
    return total;
  }

  String _getLayananNames() {
    return widget.selectedServices
        .map((e) => e['nama'] ?? 'Layanan')
        .join(', ');
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00897B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Formulir Reservasi',
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
          children: [
            // =========== PROFIL PASIEN ===========
            if (AuthService.currentUserProfile != null)
              _buildSection(
                title: 'PROFIL PASIEN',
                icon: Icons.person_outline,
                trailing: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PengaturanAkunScreen()),
                  ).then((_) => setState(() {})), // Refresh on back
                  child: const Text(
                    'Ubah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00897B),
                    ),
                  ),
                ),
                children: [
                  _buildReadOnlyRow(
                    Icons.person_outline,
                    'Nama',
                    AuthService.currentUserProfile!.nama.isEmpty
                        ? '(Belum diisi)'
                        : AuthService.currentUserProfile!.nama,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyRow(
                    Icons.cake_outlined,
                    'Tanggal Lahir',
                    AuthService.currentUserProfile!.tglLahir.isEmpty
                        ? '(Belum diisi)'
                        : AuthService.currentUserProfile!.tglLahir,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyRow(
                    Icons.location_on_outlined,
                    'Alamat',
                    AuthService.currentUserProfile!.alamat.isEmpty
                        ? '(Belum diisi)'
                        : AuthService.currentUserProfile!.alamat,
                  ),
                ],
              ),
            if (AuthService.currentUserProfile != null)
              const SizedBox(height: 16),

            // =========== LAYANAN ===========
            _buildSection(
              title: 'LAYANAN',
              icon: Icons.medical_services_outlined,
              children: [
                ...widget.selectedServices.map((service) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: Color(0xFF00897B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              service['nama'] ?? 'Layanan',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1B2E35)),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // =========== KELUHAN AWAL ===========
            _buildSection(
              title: 'KELUHAN AWAL',
              icon: Icons.health_and_safety_outlined,
              children: [
                const Text(
                  'Ceritakan keluhan atau kondisi yang Anda rasakan saat ini',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: TextField(
                    controller: _keluhanController,
                    maxLines: 4,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF1B2E35)),
                    decoration: const InputDecoration(
                      hintText:
                          'Contoh: Saya mengalami nyeri perut bagian bawah sejak 2 hari lalu...',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.black26),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: Color(0xFF00897B)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Informasi ini akan diterima oleh admin/bidan untuk mempersiapkan pelayanan terbaik.',
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF00695C),
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // =========== PILIH BIDAN ===========
            _buildSection(
              title: 'PILIH BIDAN',
              icon: Icons.people_alt_outlined,
              children: [
                const Text(
                  'Pilih bidan yang akan melayani Anda',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                ),
                const SizedBox(height: 12),
                if (_isLoadingBidan)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(
                          color: Color(0xFF00897B)),
                    ),
                  )
                else if (_bidanList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Text('Tidak ada bidan tersedia saat ini',
                            style: TextStyle(
                                fontSize: 12, color: Colors.orange)),
                      ],
                    ),
                  )
                else
                  ...(_bidanList.map((bidan) {
                    final isSelected =
                        _selectedBidanId == bidan['id']?.toString();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBidanId = bidan['id']?.toString();
                          _selectedBidanNama = bidan['nama']?.toString();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE0F2F1)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00897B)
                                : const Color(0xFFE0E0E0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isSelected
                                  ? const Color(0xFF00897B)
                                  : const Color(0xFFECEFF1),
                              child: Icon(
                                Icons.person,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF90A4AE),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bidan['nama'] ?? 'Bidan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? const Color(0xFF00695C)
                                          : const Color(0xFF1B2E35),
                                    ),
                                  ),
                                  if (bidan['spesialisasi'] != null ||
                                      bidan['pengalaman'] != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        bidan['spesialisasi'],
                                        bidan['pengalaman'] != null
                                            ? '${bidan['pengalaman']} thn pengalaman'
                                            : null,
                                      ]
                                          .where((e) => e != null)
                                          .join(' • '),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF78909C)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00897B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    size: 14, color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList()),
              ],
            ),
            const SizedBox(height: 16),

            // =========== JADWAL ===========
            _buildSection(
              title: 'JADWAL KUNJUNGAN',
              icon: Icons.calendar_today_outlined,
              children: [
                const Text('Pilih Tanggal Kunjungan',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF546E7A))),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _dateController.text =
                            "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                      });
                      _fetchExistingReservations(picked);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Pilih tanggal',
                        hintStyle: const TextStyle(
                            color: Colors.black26, fontSize: 13),
                        prefixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 18, color: Color(0xFF00897B)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0))),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Pilih Jam Kunjungan',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF546E7A))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: jamList.map((jam) {
                    final isFull = _selectedDate != null &&
                        _existingReservations.any((res) =>
                            res['jam'] == jam &&
                            res['status'] != 'Dibatalkan' &&
                            res['status'] != 'Selesai');
                    final isSelected = _selectedJam == jam;
                    return GestureDetector(
                      onTap: isFull
                          ? null
                          : () => setState(() => _selectedJam = jam),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFull
                              ? Colors.grey.shade100
                              : isSelected
                                  ? const Color(0xFF00897B)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFull
                                ? Colors.black12
                                : isSelected
                                    ? const Color(0xFF00897B)
                                    : Colors.black12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              jam,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isFull
                                    ? Colors.black26
                                    : isSelected
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                            ),
                            if (isFull) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.lock_outline,
                                  size: 11, color: Colors.black26),
                            ]
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // =========== TOMBOL KONFIRMASI ===========
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedDate == null || _selectedJam == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Mohon lengkapi Tanggal dan Jam kunjungan'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  if (_selectedBidanId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Mohon pilih bidan terlebih dahulu'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KonfirmasiReservasiScreen(
                        selectedServices: widget.selectedServices,
                        jam: _selectedJam!,
                        tanggal: _selectedDate!,
                        isHomeCare: widget.isHomeCare,
                        hargaTotal: _calculateTotalHargaRaw(),
                        layananNames: _getLayananNames(),
                        keluhan: _keluhanController.text.trim(),
                        bidanId: _selectedBidanId!,
                        bidanNama: _selectedBidanNama ?? '',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAED581),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Konfirmasi Reservasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: const Color(0xFF00897B)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00897B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF00897B)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black45)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2E35))),
            ],
          ),
        ),
      ],
    );
  }
}
