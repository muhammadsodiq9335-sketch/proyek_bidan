import 'package:flutter/material.dart';
import 'konfirmasi_reservasi_screen.dart';
import '../mock_data.dart';

class FormulirReservasiScreen extends StatefulWidget {
  final String layanan;
  final bool isHomeCare;
  const FormulirReservasiScreen({
    super.key, 
    required this.layanan, 
    this.isHomeCare = false
  });

  @override
  State<FormulirReservasiScreen> createState() =>
      _FormulirReservasiScreenState();
}

class _FormulirReservasiScreenState extends State<FormulirReservasiScreen> {
  String? _selectedLayanan;
  String? _selectedBidan;
  String? _selectedJam;
  DateTime? _selectedDate;
  final _dateController = TextEditingController();

  final List<String> jamList = [
    '08:00', '09:00', '10:00', '11:00', '13:00', '14:00'
  ];

  final List<String> layananList = [
    'Pemeriksaan Kehamilan',
    'Imunisasi Bayi',
    'Perawatan Nifas',
    'Perawatan Bayi',
  ];

  final List<String> bidanList = [
    'Bidan Salsah Amalia',
    'Bidan Siti Khadijah',
    'Bidan Rani Puspita',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLayanan = widget.layanan;
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DATA DIRI PASIEN (Read Only)
            if (MockDatabase.currentUser != null)
              _buildSection(
                title: 'PROFIL PASIEN',
                children: [
                  _buildReadOnlyRow(Icons.person_outline, 'Nama', MockDatabase.currentUser!.nama),
                  const SizedBox(height: 10),
                  _buildReadOnlyRow(Icons.cake_outlined, 'Tanggal Lahir', MockDatabase.currentUser!.tglLahir),
                  const SizedBox(height: 10),
                  _buildReadOnlyRow(Icons.location_on_outlined, 'Alamat', MockDatabase.currentUser!.alamat),
                ],
              ),
            if (MockDatabase.currentUser != null)
              const SizedBox(height: 16),

            // LAYANAN & JADWAL
            _buildSection(
              title: 'LAYANAN & JADWAL',
              children: [
                const Text('Jenis Layanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF546E7A))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLayanan,
                      hint: const Text('Pilih jenis layanan', style: TextStyle(fontSize: 13, color: Colors.black38)),
                      isExpanded: true,
                      items: layananList.map((l) {
                        return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedLayanan = val),
                    ),
                  ),
                ),
                ),
                const SizedBox(height: 12),
                const Text('Pilih Tanggal Kunjungan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF546E7A))),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _dateController.text = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Pilih tanggal',
                        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF00897B)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Pilih Jam Kunjungan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF546E7A))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: jamList.map((jam) {
                    final isSelected = _selectedJam == jam;
                    final isFull = jam == '10:00' || jam == '13:00';
                    return GestureDetector(
                      onTap: isFull ? null : () => setState(() => _selectedJam = jam),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFull
                              ? Colors.white
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
                              const Icon(Icons.lock_outline, size: 11, color: Colors.black26),
                            ]
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedBidan == null || _selectedDate == null || _selectedJam == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon lengkapi semua pilihan (Bidan, Tanggal, dan Jam)'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KonfirmasiReservasiScreen(
                        layanan: _selectedLayanan ?? widget.layanan,
                        bidan: _selectedBidan!,
                        jam: _selectedJam!,
                        tanggal: _dateController.text,
                        isHomeCare: widget.isHomeCare,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAED581),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Konfirmasi Reservasi',
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

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00897B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF546E7A))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00897B)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
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
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B2E35))),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}
