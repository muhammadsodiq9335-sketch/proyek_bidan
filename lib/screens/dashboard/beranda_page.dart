import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../notifikasi_screen.dart';
import '../riwayat_reservasi_screen.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';

class BerandaPage extends StatefulWidget {
  final Function(int) onTabChange;
  const BerandaPage({super.key, required this.onTabChange});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _lastReservations = [];
  List<Map<String, dynamic>> _bidanList = [];
  bool _isLoading = true;
  bool _hasUnreadNotif = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (AuthService.currentUserProfile == null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final profile = await _supabaseService.getUserProfile(user.id);
          AuthService.currentUserProfile = profile;
        }
      }

      final userId = AuthService.currentUserProfile?.id;
      final res = await _supabaseService.getReservasi(userId: userId);
      final bidan = await _supabaseService.getBidan();
      
      bool unread = false;
      if (userId != null) {
        final notifs = await _supabaseService.getNotifikasi(userId);
        unread = notifs.any((n) => n['is_read'] == false);
      }

      if (mounted) {
        setState(() {
          _lastReservations = res;
          _bidanList = bidan;
          _hasUnreadNotif = unread;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              _buildWelcomeSection(),
              _buildHeroBanner(context),
              _buildBidanSection(),
              _buildReservasiTerakhir(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar ──
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "MORA",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B2E35),
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  _iconCircle(
                    Icons.notifications_outlined,
                    onTap: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotifikasiScreen()));
                      _loadData(); // Refresh setelah balik
                    },
                  ),
                  if (_hasUnreadNotif)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => widget.onTabChange(4),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    image: AuthService.currentUserProfile?.fotoUrl != null && AuthService.currentUserProfile!.fotoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(AuthService.currentUserProfile!.fotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: AuthService.currentUserProfile?.fotoUrl == null || AuthService.currentUserProfile!.fotoUrl!.isEmpty
                      ? const Icon(Icons.person_outline, size: 18, color: Color(0xFF546E7A))
                      : null,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF546E7A)),
      ),
    );
  }

  // ── Welcome ──
  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Halo,",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E35),
              height: 1.2,
            ),
          ),
          Text(
            "${AuthService.currentUserProfile?.nama.split(' ')[0] ?? 'Bunda'} 👋",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Jaga kesehatanmu hari ini ya, Bunda ❤️",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withOpacity(0.5),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ── Hero Banner CTA ──
  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => widget.onTabChange(1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00897B), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00897B).withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "✨ Tersedia Layanan Klinik & Home Care",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Buat Reservasi\nSekarang",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Pilih Layanan →",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today_rounded,
                  color: Colors.white30, size: 72),
            ],
          ),
        ),
      ),
    );
  }


  // ── Reservasi Terakhir ──
  Widget _buildReservasiTerakhir(BuildContext context) {
    final bool hasReservasi = _lastReservations.isNotEmpty;
    final last = hasReservasi ? _lastReservations.first : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Reservasi Terakhir",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E35),
                ),
              ),
              if (hasReservasi)
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RiwayatReservasiScreen()),
                    );
                    _loadData();
                  },
                  child: const Text(
                    "Lihat Semua →",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00897B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (!hasReservasi)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  const Text(
                    "Belum ada reservasi",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Buat reservasi pertamamu sekarang!",
                    style: TextStyle(fontSize: 11, color: Colors.black26),
                  ),
                ],
              ),
            )
          else
            _buildLastReservasiCard(last!),
        ],
      ),
    );
  }

  Widget _buildLastReservasiCard(Map<String, dynamic> r) {
    final String status = r['status'] ?? '-';
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    if (status == 'Menunggu Persetujuan') {
      statusColor = const Color(0xFFF9A825);
      statusBg = const Color(0xFFFFF8E1);
      statusIcon = Icons.hourglass_top_rounded;
    } else if (status == 'Ditolak' || status == 'Dibatalkan') {
      statusColor = Colors.red;
      statusBg = const Color(0xFFFFEBEE);
      statusIcon = Icons.cancel_outlined;
    } else if (status == 'Selesai') {
      statusColor = Colors.blue;
      statusBg = const Color(0xFFE3F2FD);
      statusIcon = Icons.task_alt_rounded;
    } else {
      // Dikonfirmasi
      statusColor = const Color(0xFF00897B);
      statusBg = const Color(0xFFE0F2F1);
      statusIcon = Icons.check_circle_outline;
    }

    final bool isHomeCare = r['is_home_care'] == true || r['isHomeCare'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isHomeCare
                      ? Icons.home_work_outlined
                      : Icons.local_hospital_outlined,
                  color: const Color(0xFF00897B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['layanan'] ?? '-',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2E35),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHomeCare ? 'Home Care' : 'Klinik',
                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                r['tanggal'] ?? '-',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_outlined,
                  size: 13, color: Colors.black38),
              const SizedBox(width: 4),
              Text(
                r['jam'] ?? '-',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bidan Kami ──
  Widget _buildBidanSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Bidan Kami',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              'Tim bidan profesional siap melayani Bunda',
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ),
          const SizedBox(height: 14),
          if (_isLoading)
            const SizedBox(height: 190, child: Center(child: CircularProgressIndicator()))
          else if (_bidanList.isEmpty)
             const SizedBox(height: 100, child: Center(child: Text("Bidan belum tersedia", style: TextStyle(fontSize: 12, color: Colors.black26))))
          else
            SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 20),
                itemCount: _bidanList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final bidan = _bidanList[index];
                  return _buildBidanCard(bidan);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: const Color(0xFFE0F2F1),
      child: const Icon(
        Icons.person,
        color: Color(0xFF00897B),
        size: 32,
      ),
    );
  }

  Widget _buildBidanCard(Map<String, dynamic> bidan) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar + status dot
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00897B),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: (bidan['foto_url'] != null && bidan['foto_url'].toString().isNotEmpty)
                      ? Image.network(
                          bidan['foto_url'].toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
                        )
                      : _buildFallbackAvatar(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Nama
            Text(
              bidan['nama'] ?? '-',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E35),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              bidan['spesialis'] ?? 'Bidan Profesional',
              style: const TextStyle(fontSize: 10, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }


}
