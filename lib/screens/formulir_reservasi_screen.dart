import 'package:flutter/material.dart';
import 'konfirmasi_reservasi_screen.dart';

class FormulirReservasiScreen extends StatefulWidget {
  final String layanan;
  const FormulirReservasiScreen({super.key, required this.layanan});

  @override
  State<FormulirReservasiScreen> createState() =>
      _FormulirReservasiScreenState();
}

class _FormulirReservasiScreenState extends State<FormulirReservasiScreen> {
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _tglLahirController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  String? _selectedLayanan;
  String? _selectedTanggal;
  String? _selectedJam;

  final List<String> jamList = [
    '08:00', '09:00', '10:00', '11:00', '13:00', '14:00'
  ];

  final List<String> layananList = [
    'Pemeriksaan Kehamilan',
    'Imunisasi Bayi',
    'Perawatan Nifas',
    'Perawatan Bayi',
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
            // DATA DIRI PASIEN
            _buildSection(
              title: 'DATA DIRI PASIEN',
              children: [
                _buildTextField('Nama Lengkap', 'Masukkan nama sesuai KTP', _namaController),
                const SizedBox(height: 12),
                _buildTextField('NIK (Nomor Induk Kependudukan)', '16 digit nomor identitas', _nikController, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField('Tanggal Lahir (TTL)', 'mm/dd/yyyy', _tglLahirController),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Usia', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF546E7A))),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F8E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Terhitung\notomatis',
                              style: TextStyle(fontSize: 11, color: Colors.black45),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('No. Telepon/WhatsApp', '', _teleponController, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField('Alamat Lengkap', 'Jl. Mawar No. 123...', _alamatController, maxLines: 2),
              ],
            ),
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
                const SizedBox(height: 12),
                _buildTextField('Pilih Tanggal', 'mm/dd/yyyy', TextEditingController()),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KonfirmasiReservasiScreen(
                        nama: _namaController.text.isEmpty ? 'Aminah' : _namaController.text,
                        nik: _nikController.text.isEmpty ? '3271234567890001' : _nikController.text,
                        tglLahir: _tglLahirController.text.isEmpty ? 'Malang, 12 Mei 1995' : _tglLahirController.text,
                        alamat: _alamatController.text.isEmpty ? 'Jl. Simpang Ijen Blok A No.12, Malang' : _alamatController.text,
                        layanan: _selectedLayanan ?? 'Perawatan Bayi',
                        jam: _selectedJam ?? '09:00',
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
}
