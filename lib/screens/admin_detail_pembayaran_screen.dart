import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/supabase_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';
import 'admin_jadwal_screen.dart';

class AdminDetailPembayaranScreen extends StatefulWidget {
  final Map<String, dynamic> pasien;
  const AdminDetailPembayaranScreen({super.key, required this.pasien});

  @override
  State<AdminDetailPembayaranScreen> createState() => _AdminDetailPembayaranScreenState();
}

class _AdminDetailPembayaranScreenState extends State<AdminDetailPembayaranScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  bool _isFetchingServices = false;
  bool _isFetchingPaymentSettings = true;
  Map<String, dynamic> _paymentSettings = {};
  int subtotal = 85000;
  List<Map<String, dynamic>> _availableServices = [];
  final List<Map<String, dynamic>> _selectedAdditionalServices = [];
  String _selectedPaymentMethod = 'Tunai'; 
  String _selectedBank = 'BCA Syariah';    
  String _selectedQrisCode = 'A01';        

  // ── Design Tokens ──
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _bgInner = Color(0xFFFFF0F5);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _accentLight = Color(0xFFF8E1E9);
  static const _cardRadius = 16.0;
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  double _jarakKm = 0.0;
  final int _ongkosPerKm = 3000;
  final TextEditingController _jarakController = TextEditingController();

  bool get _isAlreadyPaid =>
      widget.pasien['status'] == 'Selesai' ||
      widget.pasien['status_pelayanan'] == 'Selesai & Pulang';
      
  bool get _isMenungguPembayaran => widget.pasien['status'] == 'Menunggu Pembayaran';
  bool get _isMenungguKonfirmasi => widget.pasien['status'] == 'Menunggu Konfirmasi Pembayaran';

  bool get _isLocked => _isAlreadyPaid || _isMenungguPembayaran || _isMenungguKonfirmasi;

  bool get _isHomeCare {
    final String tipeLayanan = widget.pasien['tipe_layanan'] ?? 'Klinik';
    return tipeLayanan.toLowerCase().contains('home') || widget.pasien['is_home_care'] == true;
  }

  int get tambahan => _selectedAdditionalServices.fold(0, (sum, item) {
    String priceStr = item['harga']?.toString() ?? "0";
    priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return sum + (int.tryParse(priceStr) ?? 0);
  });

  int get ongkosKirim => (_jarakKm * _ongkosPerKm).round();

  int get total => subtotal + tambahan + ongkosKirim;

  @override
  void initState() {
    super.initState();
    String priceStr = (widget.pasien['harga'] ?? "85000").toString();
    priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    subtotal = int.tryParse(priceStr) ?? 85000;
    
    _jarakKm = double.tryParse(widget.pasien['jarak_km']?.toString() ?? '0') ?? 0.0;
    _jarakController.text = _jarakKm > 0 ? _jarakKm.toString().replaceAll(RegExp(r'\.0$'), '') : "";
    
    _selectedPaymentMethod = widget.pasien['metode_pembayaran'] ?? 'Tunai';

    _fetchAvailableServices();
    _fetchPaymentSettings();
  }

  @override
  void dispose() {
    _jarakController.dispose();
    super.dispose();
  }

  Future<void> _fetchPaymentSettings() async {
    setState(() => _isFetchingPaymentSettings = true);
    try {
      final settings = await _supabaseService.getPaymentSettings();
      setState(() {
        _paymentSettings = settings;
        _selectedBank = settings['bank_name'] ?? 'BCA Syariah';
        _selectedQrisCode = settings['qris_code'] ?? 'A01';
      });
    } catch (e) {
      debugPrint("Error fetching payment settings: $e");
    } finally {
      if (mounted) setState(() => _isFetchingPaymentSettings = false);
    }
  }

  Future<void> _fetchAvailableServices() async {
    setState(() => _isFetchingServices = true);
    try {
      final services = await _supabaseService.getJenisPelayanan();
      
      // Ambil daftar nama layanan awal yang dipisahkan oleh koma
      final String initialLayananStr1 = (widget.pasien['layanan'] ?? '').toString();
      final String initialLayananStr2 = (widget.pasien['nama_layanan'] ?? '').toString();
      
      final List<String> initialLayananNames = [];
      
      if (initialLayananStr1.isNotEmpty) {
        initialLayananNames.addAll(
          initialLayananStr1.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty)
        );
      }
      if (initialLayananStr2.isNotEmpty) {
        initialLayananNames.addAll(
          initialLayananStr2.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty)
        );
      }

      setState(() {
        // Jangan tampilkan layanan yang sudah dipilih di reservasi awal (baik kecocokan ID maupun multi-nama)
        _availableServices = services.where((s) {
          final isSameId = s['id'] == widget.pasien['layanan_id'];
          
          final String currentServiceName = (s['nama'] ?? '').toString().trim().toLowerCase();
          final isSameName = initialLayananNames.contains(currentServiceName);
          
          return !isSameId && !isSameName;
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching services: $e");
    } finally {
      if (mounted) setState(() => _isFetchingServices = false);
    }
  }

  void _toggleService(Map<String, dynamic> service) {
    if (_isLocked) return; // prevent changes if already billed/paid
    setState(() {
      final index = _selectedAdditionalServices.indexWhere((s) => s['id'] == service['id']);
      if (index != -1) { _selectedAdditionalServices.removeAt(index); } else { _selectedAdditionalServices.add(service); }
    });
  }

  Future<void> _kirimTagihan() async {
    setState(() => _isLoading = true);
    try {
      if (widget.pasien['id'] != null) {
        await _supabaseService.updateReservasi(widget.pasien['id'].toString(), {
          'status': 'Menunggu Pembayaran',
          'jarak_km': _jarakKm,
          'ongkos_kirim': ongkosKirim,
          'total_tagihan': total,
          'layanan_tambahan': jsonEncode(_selectedAdditionalServices),
          'metode_pembayaran': _selectedPaymentMethod,
        });
        
        // Kirim Notifikasi ke Pasien
        if (widget.pasien['user_id'] != null) {
          await _supabaseService.tambahNotifikasi(
            userId: widget.pasien['user_id'].toString(),
            title: 'Tagihan Pembayaran 🧾',
            message: 'Tagihan untuk layanan ${widget.pasien['layanan']} telah diterbitkan. Silakan cek dan selesaikan pembayaran.',
            screen: 'riwayat',
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Tagihan berhasil dikirim ke Pasien"), backgroundColor: _accent, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        Navigator.pushNamedAndRemoveUntil(context, '/admin_pasien', (route) => route.settings.name == '/admin_dashboard');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengirim tagihan: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _konfirmasiLunas() async {
    setState(() => _isLoading = true);
    try {
      if (widget.pasien['id'] != null) {
        await _supabaseService.updateReservasi(widget.pasien['id'].toString(), {
          'status': 'Selesai', 
          'status_pelayanan': 'Selesai & Pulang',
        });
        
        // Kirim Notifikasi ke Pasien
        if (widget.pasien['user_id'] != null) {
          await _supabaseService.tambahNotifikasi(
            userId: widget.pasien['user_id'].toString(),
            title: 'Pembayaran Diterima ✨',
            message: 'Terima kasih, pembayaran untuk ${widget.pasien['layanan']} telah lunas. Yuk berikan bintang dan ulasan terbaik Bunda!',
            screen: 'riwayat',
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Pembayaran berhasil dikonfirmasi LUNAS"), backgroundColor: _accent, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        Navigator.pushNamedAndRemoveUntil(context, '/admin_ringkasan', (route) => route.settings.name == '/admin_dashboard');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal konfirmasi: $e")));
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

  @override
  Widget build(BuildContext context) {
    final pasien = widget.pasien;
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
        title: const Text("Detail Pembayaran", style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: _isFetchingPaymentSettings
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
          // ── INFO PASIEN ──
          _cardContainer(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: _accentLight,
                    backgroundImage: (pasien['foto_url'] != null && pasien['foto_url'].toString().trim().isNotEmpty)
                        ? NetworkImage(pasien['foto_url'].toString())
                        : null,
                    child: (pasien['foto_url'] == null || pasien['foto_url'].toString().trim().isEmpty)
                        ? Text(
                            ((pasien['nama_pasien'] ?? pasien['namaPasien'] ?? '-')[0]).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 18),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('INFORMASI PASIEN', style: TextStyle(fontSize: 10, color: _textSecondary, letterSpacing: 0.8, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          pasien['nama_pasien'] ?? pasien['namaPasien'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Builder(
                          builder: (context) {
                            final String patientId = pasien['user_id'] != null 
                                ? pasien['user_id'].toString().substring(0, 8).toUpperCase() 
                                : '-';
                            // Deteksi Home Care dari is_home_care, tipe_layanan, atau isHomeCare
                            final bool isHomeCare = pasien['is_home_care'] == true ||
                                pasien['isHomeCare'] == true ||
                                (pasien['tipe_layanan']?.toString().toLowerCase().contains('home') ?? false);
                            final String badgeLabel = isHomeCare ? 'Home Care' : 'Klinik';
                            final String tanggal = pasien['tanggal'] ?? '-';
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                      ),
                                      child: Text(
                                        "ID: #$patientId",
                                        style: const TextStyle(fontSize: 9, color: _textSecondary, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isHomeCare 
                                            ? const Color(0xFFE3F2FD) 
                                            : const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isHomeCare 
                                              ? const Color(0xFF90CAF9) 
                                              : const Color(0xFFA5D6A7),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        badgeLabel,
                                        style: TextStyle(
                                          fontSize: 9, 
                                          color: isHomeCare 
                                              ? const Color(0xFF1565C0) 
                                              : const Color(0xFF2E7D32), 
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 11, color: _textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Tanggal Pemeriksaan: $tanggal",
                                      style: const TextStyle(fontSize: 11, color: _textSecondary, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _bgInner, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  const Text("Layanan yang dibayar pasien :", style: TextStyle(fontSize: 10, color: _textSecondary)),
                  const SizedBox(height: 4),
                  Text(pasien['layanan'] ?? '-', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(_formatCurrency(subtotal), style: const TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 14)),
                ]),
              ),
            ],
          )),

          const SizedBox(height: 14),

          // ── LAYANAN TAMBAHAN ──
          _cardContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Layanan Tambahan", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
              if (!_isLocked)
                TextButton.icon(
                  onPressed: _showAddServiceSheet,
                  icon: const Icon(Icons.add_circle_rounded, size: 16, color: _accent),
                  label: const Text('Tambah', style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: _accentLight,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ]),
            const SizedBox(height: 4),
            Text(_isLocked ? "Rincian biaya telah dikunci" : "Pilih layanan tambahan jika diperlukan", style: const TextStyle(fontSize: 11, color: _textSecondary)),
            const SizedBox(height: 14),
            if (_selectedAdditionalServices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: _textSecondary),
                    SizedBox(width: 6),
                    Text("Belum ada layanan tambahan ditambahkan", style: TextStyle(fontSize: 12, color: _textSecondary)),
                  ],
                ),
              )
            else
              ..._selectedAdditionalServices.map((service) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _selectedServiceItem(
                    title: service['nama'] ?? '-',
                    durasi: service['deskripsi'] ?? service['durasi'] ?? '-',
                    harga: int.tryParse(service['harga']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0,
                    onDelete: () => _toggleService(service),
                  ),
                );
              }),
          ])),

          const SizedBox(height: 14),

          // ── ONGKOS KIRIM ──
          if (_isHomeCare) ...[
            _buildOngkosKirimSection(),
            const SizedBox(height: 14),
          ],

          // ── RINGKASAN TAGIHAN ──
          _cardContainer(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.receipt_long_rounded, size: 18, color: _accent),
              SizedBox(width: 8),
              Text("Ringkasan Tagihan", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
            ]),
            const SizedBox(height: 14),
            _rowHarga("Subtotal Reservasi Awal", subtotal),
            if (_selectedAdditionalServices.isNotEmpty) ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
              const Text("Total Layanan Tambahan:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary)),
              const SizedBox(height: 4),
              ..._selectedAdditionalServices.map((service) {
                int price = int.tryParse(service['harga']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
                return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: _rowHarga(service['nama'] ?? '-', price, isSmall: true));
              }),
            ],
            if (_isHomeCare && _jarakKm > 0) ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Colors.black12)),
              _rowHarga("Ongkos Kirim (${_jarakKm.toString().replaceAll(RegExp(r'\.0$'), '')} km)", ongkosKirim),
            ],
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Colors.black12)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Total Tagihan", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 14)),
              Text(_formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 18)),
            ]),
          ])),

          const SizedBox(height: 14),

          // ── METODE PEMBAYARAN ──
          _buildMetodePembayaranSection(),

          const SizedBox(height: 20),

          // ── BUTTON ──
          if (_isAlreadyPaid)
            _buildPrimaryButton(
              onPressed: null,
              icon: Icons.check_circle_rounded,
              label: "Pembayaran Lunas",
              color: const Color(0xFF4CAF50),
            )
          else if (_isMenungguPembayaran)
            _buildPrimaryButton(
              onPressed: null,
              icon: Icons.access_time_filled_rounded,
              label: "Menunggu Pasien Membayar...",
              color: Colors.orange,
            )
          else if (_isMenungguKonfirmasi)
            _buildPrimaryButton(
              onPressed: _isLoading ? null : _konfirmasiLunas,
              icon: Icons.verified_rounded,
              label: "Verifikasi & Konfirmasi Lunas",
              color: _accent,
            )
          else 
            _buildPrimaryButton(
              onPressed: _isLoading ? null : _kirimTagihan,
              icon: Icons.send_rounded,
              label: "Kirim Tagihan ke Pasien",
              color: _accent,
            ),
          const SizedBox(height: 10),
        ]),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _buildPrimaryButton({required VoidCallback? onPressed, required IconData icon, required String label, required Color color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: _isLoading && onPressed != null
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.6),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildOngkosKirimSection() {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.two_wheeler_rounded, size: 18, color: _accent),
                  SizedBox(width: 8),
                  Text("Ongkos Transportasi", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${_formatCurrency(_ongkosPerKm)}/km",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _bgInner,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withOpacity(0.1), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Jarak Tempuh (km)", style: TextStyle(fontSize: 12, color: _textSecondary)),
                    SizedBox(
                      width: 80,
                      height: 36,
                      child: TextField(
                        controller: _jarakController,
                        enabled: !_isLocked,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                          filled: true,
                          fillColor: _isAlreadyPaid ? Colors.grey.shade100 : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: _accent),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            final normalized = val.replaceAll(',', '.');
                            _jarakKm = double.tryParse(normalized) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Estimasi Ongkos", style: TextStyle(fontSize: 12, color: _textSecondary)),
                    Text(_formatCurrency(ongkosKirim), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetodePembayaranSection() {
    final String bankName = _paymentSettings['bank_name'] ?? 'BCA Syariah';
    final String rekNumber = _paymentSettings['rek_number'] ?? '0631999999';
    final String rekName = _paymentSettings['rek_name'] ?? 'A.n ANNISA';
    final String qrisNmid = _paymentSettings['qris_nmid'] ?? 'ID1026496531744';
    final String qrisName = _paymentSettings['qris_name'] ?? 'TAMAN IBU BIDAN ANNISA - HOME SERVICE';
    final String qrisCode = _paymentSettings['qris_code'] ?? 'A01';
    final String qrisUrl = _paymentSettings['qris_url'] ?? '';

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.payment_rounded, size: 18, color: _accent),
              SizedBox(width: 8),
              Text(
                "Metode Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Row Pilihan (Tabs)
          Row(
            children: [
              _buildPaymentTab('Tunai', Icons.money_rounded),
              const SizedBox(width: 8),
              _buildPaymentTab('Transfer', Icons.account_balance_rounded),
              const SizedBox(width: 8),
              _buildPaymentTab('QRIS', Icons.qr_code_2_rounded),
            ],
          ),
          const SizedBox(height: 16),

          // Detail Berdasarkan Pilihan
          if (_selectedPaymentMethod == 'Tunai')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF81C784).withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pembayaran dilakukan secara tunai (cash) langsung kepada Bidan.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          else if (_selectedPaymentMethod == 'Transfer') ...[
            const Text(
              "Rekening Transfer Tujuan :",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary),
            ),
            const SizedBox(height: 6),
            // Tampilan info rekening
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bgInner,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accent.withOpacity(0.1), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bankName.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: _accent, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: rekNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Nomor rekening berhasil disalin!"),
                              backgroundColor: _accent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _accentLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.copy_rounded, size: 12, color: _accent),
                              SizedBox(width: 4),
                              Text(
                                "Salin",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Nomor Rekening:",
                    style: TextStyle(fontSize: 10, color: _textSecondary),
                  ),
                  Text(
                    rekNumber,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Nama Penerima:",
                    style: TextStyle(fontSize: 10, color: _textSecondary),
                  ),
                  Text(
                    rekName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textPrimary),
                  ),
                ],
              ),
            ),
          ] else if (_selectedPaymentMethod == 'QRIS') ...[
            const Text(
              "QRIS Pembayaran Klinik :",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _textSecondary),
            ),
            const SizedBox(height: 6),
            // Tampilan QRIS Gambar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bgInner,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accent.withOpacity(0.1), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    qrisName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "NMID : $qrisNmid",
                    style: const TextStyle(color: _textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Kode: $qrisCode",
                    style: const TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  // Frame QRIS Gambar
                  GestureDetector(
                    onTap: () => _showLargeQRISDialog(context, qrisUrl, qrisName, qrisNmid, qrisCode),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _cardShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: qrisUrl.isNotEmpty
                              ? Image.network(
                                  qrisUrl,
                                  height: 260,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/qris.jpg',
                                      height: 260,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _qrisErrorPlaceholder();
                                      },
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/qris.jpg',
                                  height: 260,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _qrisErrorPlaceholder();
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showLargeQRISDialog(context, qrisUrl, qrisName, qrisNmid, qrisCode),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.zoom_in_rounded, size: 14, color: _accent),
                        SizedBox(width: 4),
                        Text(
                          "Ketuk gambar untuk memperbesar QRIS",
                          style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _qrisErrorPlaceholder() {
    return Container(
      height: 150,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.broken_image_rounded, color: Colors.grey, size: 36),
          SizedBox(height: 8),
          Text(
            "Gagal memuat gambar QRIS\nPastikan aset terdaftar",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showLargeQRISDialog(BuildContext context, String qrisUrl, String qrisName, String qrisNmid, String qrisCode) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeOutBack,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Scan QRIS Pembayaran",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  qrisName.toUpperCase(),
                                  style: const TextStyle(fontSize: 11, color: _accent, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, color: _textSecondary),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 3.0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: qrisUrl.isNotEmpty
                                ? Image.network(
                                    qrisUrl,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/qris.jpg',
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _qrisErrorPlaceholder();
                                        },
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/qris.jpg',
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _qrisErrorPlaceholder();
                                    },
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _bgInner,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "NMID: $qrisNmid",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Kode: $qrisCode",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.zoom_in_rounded, size: 14, color: _textSecondary),
                          SizedBox(width: 6),
                          Text(
                            "Gunakan 2 jari untuk memperbesar gambar",
                            style: TextStyle(fontSize: 10, color: _textSecondary, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentTab(String method, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: _isLocked ? null : () => setState(() => _selectedPaymentMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _accent : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _accent : Colors.grey.shade300,
              width: 1.2,
            ),
            boxShadow: isSelected ? _cardShadow : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : _textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                method,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : _textPrimary,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(_cardRadius), boxShadow: _cardShadow), child: child);
  }

  Widget _selectedServiceItem({required String title, required String durasi, required int harga, required VoidCallback onDelete}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgInner,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withOpacity(0.1), width: 1),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
          const SizedBox(height: 2),
          Text(durasi, style: const TextStyle(fontSize: 11, color: _textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 8),
        Text(_formatCurrency(harga), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _accent)),
        const SizedBox(width: 12),
        if (!_isLocked)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
      ]),
    );
  }

  void _showAddServiceSheet() {
    String searchQuery = "";
    bool isHomeCareTab = false;
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredServices = _availableServices.where((service) {
              final nama = (service['nama'] ?? '').toString().toLowerCase();
              final deskripsi = (service['deskripsi'] ?? service['durasi'] ?? '').toString().toLowerCase();
              final query = searchQuery.toLowerCase();
              final matchesSearch = nama.contains(query) || deskripsi.contains(query);

              final isHomeCareService = service['is_home_care'] == true;
              final matchesTab = isHomeCareService == isHomeCareTab;

              return matchesSearch && matchesTab;
            }).toList();

            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Pilih Layanan Tambahan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Cari layanan...",
                        hintStyle: const TextStyle(color: _textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: _textSecondary, size: 20),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: _textSecondary, size: 18),
                                onPressed: () {
                                  searchController.clear();
                                  setModalState(() {
                                    searchQuery = "";
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tab Toggle
                  Container(
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                isHomeCareTab = false;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !isHomeCareTab ? _accent : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Layanan Klinik",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !isHomeCareTab ? Colors.white : _textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                isHomeCareTab = true;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isHomeCareTab ? _accent : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Home Care",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isHomeCareTab ? Colors.white : _textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List
                  Expanded(
                    child: _isFetchingServices
                        ? const Center(child: CircularProgressIndicator(color: _accent))
                        : filteredServices.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Layanan tidak ditemukan",
                                      style: TextStyle(color: _textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredServices.length,
                                itemBuilder: (context, index) {
                                  final service = filteredServices[index];
                                  final isSelected = _selectedAdditionalServices.any((s) => s['id'] == service['id']);
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _modalServiceItem(
                                      title: service['nama'] ?? '-',
                                      deskripsi: service['deskripsi'] ?? service['durasi'] ?? '-',
                                      harga: int.tryParse(service['harga']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0,
                                      kategori: service['kategori'] ?? 'Layanan',
                                      isSelected: isSelected,
                                      onTap: () {
                                        _toggleService(service);
                                        setModalState(() {});
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 16),

                  // Selesai Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Selesai",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _modalServiceItem({
    required String title,
    required String deskripsi,
    required int harga,
    required String kategori,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _accent : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? _accent.withOpacity(0.04) : Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deskripsi,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatCurrency(harga),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _accent,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          kategori,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? _accent : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? _accent : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowHarga(String title, int value, {bool isSmall = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: TextStyle(fontSize: isSmall ? 12 : 13, color: isSmall ? _textSecondary : _textPrimary)),
      Text(_formatCurrency(value), style: TextStyle(fontSize: isSmall ? 12 : 13, fontWeight: isSmall ? FontWeight.normal : FontWeight.w600, color: isSmall ? _textSecondary : _textPrimary)),
    ]);
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, type: BottomNavigationBarType.fixed, selectedItemColor: _accent, unselectedItemColor: const Color(0xFFB0BEC5),
      onTap: (index) {
        if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
        if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
        if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPengaturanScreen()));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}
