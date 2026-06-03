import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class PasienTagihanScreen extends StatefulWidget {
  final Map<String, dynamic> pasien;
  const PasienTagihanScreen({super.key, required this.pasien});

  @override
  State<PasienTagihanScreen> createState() => _PasienTagihanScreenState();
}

class _PasienTagihanScreenState extends State<PasienTagihanScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final NotificationService _notifService = NotificationService();
  bool _isLoading = false;
  bool _hasPaid = false;
  bool _isFetchingPaymentSettings = true;
  Map<String, dynamic> _paymentSettings = {};
  
  late String _selectedPaymentMethod;

  // Design Tokens
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _bgInner = Color(0xFFFFF0F5);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _accentLight = Color(0xFFF8E1E9);
  static const _cardRadius = 16.0;
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.pasien['metode_pembayaran'] ?? 'Transfer';
    _hasPaid = widget.pasien['status'] != 'Menunggu Pembayaran';
    _fetchPaymentSettings();
  }

  Future<void> _fetchPaymentSettings() async {
    try {
      final settings = await _supabaseService.getPaymentSettings();
      setState(() {
        _paymentSettings = settings;
      });
    } catch (e) {
      debugPrint("Error fetching payment settings: $e");
    } finally {
      if (mounted) setState(() => _isFetchingPaymentSettings = false);
    }
  }

  Future<void> _konfirmasiBayar() async {
    if (_hasPaid) return;
    setState(() => _isLoading = true);
    try {
      await _supabaseService.updateReservasi(widget.pasien['id'].toString(), {
        'status': 'Menunggu Konfirmasi Pembayaran',
      });
      setState(() => _hasPaid = true);
      // Bunyi + Getar sebagai feedback konfirmasi
      await _notifService.notify();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Konfirmasi berhasil terkirim. Menunggu verifikasi Bidan."), backgroundColor: _accent));
        Navigator.pop(context, true); // Send true back to trigger refresh
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(int value) {
    final str = value.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) result.write('.');
    }
    return "Rp ${result.toString().split('').reversed.join()}";
  }

  Widget _cardContainer({required Widget child}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(_cardRadius), boxShadow: _cardShadow), child: child);
  }

  @override
  Widget build(BuildContext context) {
    // Parse data
    int subtotal = int.tryParse(widget.pasien['harga']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '85000') ?? 85000;
    int ongkosKirim = widget.pasien['ongkos_kirim'] ?? 0;
    double jarakKm = double.tryParse(widget.pasien['jarak_km']?.toString() ?? '0') ?? 0.0;
    int totalTagihan = widget.pasien['total_tagihan'] ?? (subtotal + ongkosKirim);
    
    List<dynamic> layananTambahan = [];
    try {
      if (widget.pasien['layanan_tambahan'] != null) {
        layananTambahan = jsonDecode(widget.pasien['layanan_tambahan']);
      }
    } catch (e) {
      debugPrint("Error parsing layanan tambahan: $e");
    }

    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        title: const Text("Tagihan Pembayaran", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: _isFetchingPaymentSettings ? const Center(child: CircularProgressIndicator(color: _accent)) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rincian Tagihan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPrimary)),
                  const SizedBox(height: 16),
                  _rowItem(widget.pasien['layanan'] ?? "Layanan Utama", subtotal),
                  if (layananTambahan.isNotEmpty) ...[
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Colors.black12)),
                    const Text("Layanan Tambahan:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary)),
                    const SizedBox(height: 6),
                    ...layananTambahan.map((s) {
                      int price = int.tryParse(s['harga']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
                      return Padding(padding: const EdgeInsets.only(bottom: 4), child: _rowItem(s['nama'] ?? '-', price, isSmall: true));
                    }),
                  ],
                  if (ongkosKirim > 0) ...[
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Colors.black12)),
                    _rowItem("Ongkos Transportasi (${jarakKm.toString().replaceAll(RegExp(r'\.0$'), '')} km)", ongkosKirim),
                  ],
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.black12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Tagihan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPrimary)),
                      Text(_formatCurrency(totalTagihan), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _accent)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMetodePembayaranSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isLoading || _hasPaid) ? null : _konfirmasiBayar,
                icon: _isLoading 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  widget.pasien['status'] == 'Selesai' || widget.pasien['status_pelayanan'] == 'Selesai & Pulang'
                      ? "Pembayaran Lunas"
                      : (_hasPaid ? "Menunggu Verifikasi" : "Saya Sudah Bayar"), 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _accent.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _rowItem(String title, int value, {bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(title, style: TextStyle(fontSize: isSmall ? 12 : 14, color: isSmall ? _textSecondary : _textPrimary)),
        ),
        const SizedBox(width: 8),
        Text(_formatCurrency(value), style: TextStyle(fontSize: isSmall ? 12 : 14, fontWeight: isSmall ? FontWeight.normal : FontWeight.w600, color: isSmall ? _textSecondary : _textPrimary)),
      ],
    );
  }

  Widget _buildMetodePembayaranSection() {
    final bankName = _paymentSettings['bank_name'] ?? 'BCA Syariah';
    final rekNumber = _paymentSettings['rek_number'] ?? '0631999999';
    final rekName = _paymentSettings['rek_name'] ?? 'A.n ANNISA';
    final qrisCode = _paymentSettings['qris_code'] ?? 'A01';
    final qrisUrl = _paymentSettings['qris_url'] ?? '';

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Metode Pembayaran (Dipilih oleh Bidan)", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
          const SizedBox(height: 14),
          if (_selectedPaymentMethod == 'Transfer') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _bgInner, borderRadius: BorderRadius.circular(12), border: Border.all(color: _accent.withOpacity(0.1))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(bankName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 14)),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: rekNumber));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Nomor disalin!"), backgroundColor: _accent));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _accentLight, borderRadius: BorderRadius.circular(6)),
                          child: const Text("Salin", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _accent)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("No. Rekening:", style: TextStyle(fontSize: 11, color: _textSecondary)),
                  Text(rekNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary)),
                  const SizedBox(height: 4),
                  Text("A.n $rekName", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textPrimary)),
                ],
              ),
            ),
          ] else if (_selectedPaymentMethod == 'QRIS') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _bgInner, borderRadius: BorderRadius.circular(12), border: Border.all(color: _accent.withOpacity(0.1))),
              child: Column(
                children: [
                  Text("Kode QRIS: $qrisCode", style: const TextStyle(fontWeight: FontWeight.bold, color: _accent)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: qrisUrl.isNotEmpty
                          ? Image.network(qrisUrl, height: 250, fit: BoxFit.contain)
                          : Image.asset('assets/images/qris.jpg', height: 250, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Container(height: 150, alignment: Alignment.center, child: const Icon(Icons.broken_image, color: Colors.grey))),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_selectedPaymentMethod == 'Tunai') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF81C784).withOpacity(0.3))),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text("Silakan berikan pembayaran tunai langsung kepada Bidan yang bertugas.", style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

}
