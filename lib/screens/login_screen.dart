import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import '../mock_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Toggle state: true for Pasien, false for Admin
  bool isPatientMode = true;
  
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Soft pink background requested in the design
      backgroundColor: const Color(0xFFFCE4EC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Toggle Role (Segmented Control)
                  _buildRoleToggle(),
                  const SizedBox(height: 20),
                  // The main Login Card
                  _buildLoginCard(context),
                  const SizedBox(height: 20),
                  // Waiting Room Image / Footer banner
                  _buildFooterBanner(),
                  const SizedBox(height: 20),
                  _buildCopyright()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            title: "Pasien",
            isSelected: isPatientMode,
            onTap: () => setState(() => isPatientMode = true),
          ),
          _buildToggleButton(
            title: "Admin",
            isSelected: !isPatientMode,
            onTap: () => setState(() => isPatientMode = false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFAED581) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9), // Pale Background Green
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Title
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 2),
              ),
              child: const Icon(Icons.medical_services_outlined, size: 40, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "MORA",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xFF1B2E35),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              isPatientMode 
                  ? "Selamat datang. Silakan masuk\nke akun reservasi bidan Anda."
                  : "Selamat datang Admin.\nMasuk untuk mengelola sistem.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Email Field
          const Text("Email atau No. HP", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Masukkan email atau no. hp Anda",
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
              prefixIcon: const Icon(Icons.person_outline, color: Colors.black38, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Password Field
          const Text("Kata Sandi", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              hintText: "Masukkan kata sandi Anda",
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.black38, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                  color: Colors.black38, 
                  size: 20
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: false,
                      onChanged: (val) {},
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Ingat saya", style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
              const Text(
                "Lupa kata sandi?",
                style: TextStyle(fontSize: 12, color: Color(0xFF9CCC65), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Login Button
          ElevatedButton(
            onPressed: () {
              final email = _emailController.text.trim();
              final password = _passwordController.text.trim();

              // Validasi field kosong
              if (email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Email/No. HP dan Kata Sandi harus diisi!"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              // Validasi role mode
              if (isPatientMode) {
                // Cek apakan email/hp sudah terdaftar di MockDatabase
                if (!MockDatabase.registeredUsers.containsKey(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Akun belum terdaftar. Silakan daftar terlebih dahulu!"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                // Cek kecocokan password
                if (MockDatabase.registeredUsers[email] != password) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kata Sandi salah!"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                // Login sukses, set pengguna aktif
                MockDatabase.currentUser = MockDatabase.userProfiles[email] ?? UserProfile(
                  email: email, 
                  nama: "Pengguna", 
                  tglLahir: "-", 
                  alamat: "-"
                );
              } else {
                // Admin mode: hardcoded untuk demo
                if (email != "admin@gmail.com" || password != "admin") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kredensial Admin tidak valid! (Gunakan admin / admin)"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
              }

              // Jika lolos semua validasi
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Login berhasil!"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );

              Future.delayed(const Duration(seconds: 1), () {
                if (!mounted) return;
                if (isPatientMode) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAED581),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Masuk",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Register
          if (isPatientMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum punya akun? ", style: TextStyle(fontSize: 13, color: Colors.black54)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Daftar sekarang",
                    style: TextStyle(fontSize: 13, color: const Color(0xFF9CCC65).withOpacity(0.9), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildFooterBanner() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=2053&auto=format&fit=crop"),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ]
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: const Text(
          "Melayani layanan kebidanan modern dengan kasih sayang dan kepedulian sejak 2010.",
          style: TextStyle(color: Colors.white, fontSize: 11, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Column(
      children: [
        const Text(
          "© 2026 Bidan Mandiri. Hak cipta dilindungi undang-undang.",
          style: TextStyle(fontSize: 10, color: Colors.black45),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Kebijakan Privasi", style: TextStyle(fontSize: 10, color: Colors.black45)),
            Text("  •  ", style: TextStyle(fontSize: 10, color: Colors.black45)),
            Text("Ketentuan Layanan", style: TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        )
      ],
    );
  }
}
