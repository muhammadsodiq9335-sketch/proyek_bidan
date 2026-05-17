import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pengaturan_notif_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_cek_profil_bidan_screen.dart';
import 'admin_jenis_pelayanan_screen.dart';
import 'admin_review_pasien_screen.dart';
import 'admin_chat_list_screen.dart';
import 'admin_artikel_screen.dart';
import 'admin_laporan_screen.dart';

class AdminPengaturanScreen extends StatefulWidget {
  const AdminPengaturanScreen({super.key});

  @override
  State<AdminPengaturanScreen> createState() => _AdminPengaturanScreenState();
}

class _AdminPengaturanScreenState extends State<AdminPengaturanScreen> {

  // ================= DESIGN TOKENS =================
  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _bgInner = Color(0xFFFFF0F5);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _accentLight = Color(0xFFE0F2F1);
  static const _cardRadius = 16.0;
  static const _cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildMenuItems(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PengaturanNotifikasiScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _bgInner,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Akun',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kelola data profesional dan layanan Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final List<MenuItemData> menuItems = [
      MenuItemData(
        icon: Icons.person_outline,
        title: 'Cek Profil Bidan',
        subtitle: 'Lihat dan Perbarui Identitas',
        iconColor: const Color(0xFFC2185B),
      ),
      MenuItemData(
        icon: Icons.star_outline,
        title: 'Cek Review Pasien',
        subtitle: '+ 4.8 Rating Pengguna',
        iconColor: const Color(0xFFFFA726),
      ),
      MenuItemData(
        icon: Icons.healing_outlined,
        title: 'Jenis Pelayanan',
        subtitle: 'Ubah, Hapus, dll',
        iconColor: const Color(0xFF29B6F6),
      ),
      MenuItemData(
        icon: Icons.assessment_outlined,
        title: 'Pelaporan',
        subtitle: 'Rekam Pelaporan',
        iconColor: const Color(0xFFAB47BC),
      ),
      MenuItemData(
        icon: Icons.article_outlined,
        title: 'Upload Artikel',
        subtitle: 'Upload Artikel Terbaru',
        iconColor: const Color(0xFF42A5F5),
      ),
      MenuItemData(
        icon: Icons.logout,
        title: 'Log Out',
        subtitle: 'Akhiri sesi',
        iconColor: const Color(0xFFE53935),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: menuItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildMenuItem(item, context),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(MenuItemData item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.title == 'Log Out') {
          _showLogoutConfirmation(context);
        } else if (item.title == 'Cek Profil Bidan') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCekProfilBidanScreen()));
        } else if (item.title == 'Cek Review Pasien') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminReviewPasienScreen()));
        } else if (item.title == 'Jenis Pelayanan') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminJenisPelayananScreen()));
        } else if (item.title == 'Upload Artikel') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminArtikelScreen()));
        } else if (item.title == 'Pelaporan') {
          Navigator.pushNamed(context, '/admin_laporan');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: _textPrimary)),
                    const SizedBox(height: 2),
                    Text(item.subtitle,
                        style: const TextStyle(fontSize: 12, color: _textSecondary)),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _bgInner,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 12, color: _textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Log Out', style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
          content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: _textSecondary)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: _textSecondary))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  /// ================= NAV =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFC2185B),
      unselectedItemColor: const Color(0xFFB0BEC5),

      onTap: (index) {
        if (index == 4) return;
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/admin_jadwal');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/admin_chat_list');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/admin_pembayaran');
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });
}
