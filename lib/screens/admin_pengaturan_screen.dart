import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';

class AdminPengaturanScreen extends StatefulWidget {
  const AdminPengaturanScreen({super.key});

  @override
  State<AdminPengaturanScreen> createState() => _AdminPengaturanScreenState();
}

class _AdminPengaturanScreenState extends State<AdminPengaturanScreen> {
  int _currentIndex = 3; // Pengaturan tab index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),
              const SizedBox(height: 24),
              // Menu Items
              _buildMenuItems(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: const Icon(Icons.notifications_outlined,
                  size: 18, color: Color(0xFF546E7A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // White Card with Header Info
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengaturan Akun',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2E35),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
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
        icon: Icons.logout,
        title: 'Log Out',
        subtitle: 'Akhiri sesi',
        iconColor: const Color(0xFFE53935),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: menuItems.map<Widget>((item) {
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
        }
        // Add navigation for other menu items as needed
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2E35),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFCCCCCC),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Log Out'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminJadwalScreen()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: const Color(0xFFB0BEC5),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.5,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'BERANDA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'JADWAL',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'PASIEN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'PENGATURAN',
          ),
        ],
      ),
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