import 'package:flutter/material.dart';
import '../login_screen.dart';
import '../riwayat_reservasi_screen.dart';
import '../notifikasi_screen.dart';
import '../pusat_bantuan_screen.dart';
import '../pengaturan_akun_screen.dart';
import '../../services/auth_service.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Avatar
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengaturanAkunScreen())),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(color: const Color(0xFF00897B), width: 3),
                        image: AuthService.currentUserProfile?.fotoUrl != null && AuthService.currentUserProfile!.fotoUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(AuthService.currentUserProfile!.fotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: AuthService.currentUserProfile?.fotoUrl == null || AuthService.currentUserProfile!.fotoUrl!.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengaturanAkunScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00897B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Text(
                  AuthService.currentUserProfile?.nama ?? 'Mama',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E35),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthService.currentUserProfile?.email ?? "+62 812-3456-7890",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ]
            ),
            const SizedBox(height: 30),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildProfileMenu(
                    context,
                    Icons.history,
                    "Riwayat Reservasi",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const RiwayatReservasiScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    context,
                    Icons.notifications_none,
                    "Notifikasi",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotifikasiScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    context,
                    Icons.help_outline,
                    "Pusat Bantuan",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PusatBantuanScreen())),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _buildProfileMenu(
                    context,
                    Icons.settings_outlined,
                    "Pengaturan Akun",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const PengaturanAkunScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text("Konfirmasi Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx); // Tutup dialog
                              AuthService.currentUserProfile = null;
                              if (!context.mounted) return;
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "Keluar",
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, IconData icon, String title,
      {bool isComingSoon = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF00897B), size: 20),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isComingSoon ? Colors.black26 : const Color(0xFF1B2E35),
            ),
          ),
          if (isComingSoon) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "COMING SOON",
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber),
              ),
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: isComingSoon ? null : (onTap ?? () {}),
    );
  }
}
