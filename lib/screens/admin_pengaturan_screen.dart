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

class AdminPengaturanScreen extends StatefulWidget {
  const AdminPengaturanScreen({super.key});

  @override
  State<AdminPengaturanScreen> createState() => _AdminPengaturanScreenState();
}

class _AdminPengaturanScreenState extends State<AdminPengaturanScreen> {
  int _currentIndex = 4; // ✅ index pengaturan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMenuItems(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      /// ✅ FIX NAV
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E35),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: Color(0xFF546E7A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan Akun',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kelola data profesional dan layanan Anda',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
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
        iconColor: const Color(0xFF00897B),
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
            padding: const EdgeInsets.only(bottom: 12),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AdminCekProfilBidanScreen(),
            ),
          );
        } else if (item.title == 'Cek Review Pasien') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AdminReviewPasienScreen(),
            ),
          );
        } else if (item.title == 'Jenis Pelayanan') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AdminJenisPelayananScreen(),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(item.subtitle,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
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
          title: const Text('Konfirmasi Log Out'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Log Out',
                  style: TextStyle(color: Colors.red)),
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
      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: const Color(0xFFB0BEC5),

      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        }
        if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminJadwalScreen()));
        }
        if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => AdminChatListScreen()));
        }
        if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminPasienScreen()));
        }
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
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