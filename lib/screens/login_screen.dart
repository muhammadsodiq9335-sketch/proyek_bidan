import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();

    // Inisialisasi animasi melayang untuk maskot
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // Dengarkan perubahan status otentikasi (untuk menangkap deep link lupa sandi)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        _showUpdatePasswordDialog();
      }
    });
  }

  Future<void> _loadRememberMe() async {
    final authService = AuthService();
    final data = await authService.getRememberMe();
    setState(() {
      _rememberMe = data['isRemembered'];
      if (_rememberMe && data['email'].isNotEmpty) {
        _emailController.text = data['email'];
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _floatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showUpdatePasswordDialog() {
    final passCtrl = TextEditingController();
    bool isSaving = false;
    
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan klik luar
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Perbarui Kata Sandi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Masukkan kata sandi baru Anda di bawah ini.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Kata Sandi Baru',
                    filled: true,
                    fillColor: const Color(0xFFF4F7F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (isSaving)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    if (passCtrl.text.trim().isEmpty) return;
                    setDialogState(() => isSaving = true);
                    try {
                      await Supabase.instance.client.auth.updateUser(
                        UserAttributes(password: passCtrl.text.trim()),
                      );
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kata sandi berhasil diperbarui! Silakan masuk.')),
                      );
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7EAC6D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
            ],
          );
        }
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_reset_rounded, color: Color(0xFFF78E91), size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Lupa Kata Sandi?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan email terdaftar Anda. Kami akan mengirimkan informasi pemulihan kata sandi.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Masukkan Email Anda',
                  hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF7EAC6D), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.black45, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harap masukkan email Anda terlebih dahulu')),
                );
                return;
              }

              Navigator.pop(ctx); // Tutup dialog

              // Tampilkan loading sebentar
              setState(() => _isLoading = true);

              try {
                final supabaseService = SupabaseService();
                await supabaseService.resetPassword(email);

                if (!mounted) return;
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Email pemulihan kata sandi telah dikirim ke $email'),
                    backgroundColor: const Color(0xFF7EAC6D),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengirim pemulihan: ${e.toString().replaceAll('Exception: ', '')}'),
                    backgroundColor: const Color(0xFFF78E91),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7EAC6D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Kirim',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Email dan Kata Sandi harus diisi!",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFF78E91),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = AuthService();

    try {
      print('LOGIN PROCESS: Attempting login for $email');
      await authService.signIn(email: email, password: password);
      await authService.saveRememberMe(email, _rememberMe);

      final profile = AuthService.currentUserProfile;
      if (profile == null) throw Exception("Profil tidak ditemukan di database.");

      final role = profile.role.toLowerCase().trim();
      print('LOGIN SUCCESS: User detected as "$role"');

      if (!mounted) return;
      setState(() => _isLoading = false);

      // AUTOMATIC ROLE-BASED REDIRECTION
      if (role == 'admin') {
        print('LOGIN REDIRECT: To Admin Dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      } else {
        print('LOGIN REDIRECT: To Patient Dashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      print('LOGIN ERROR: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login gagal: ${e.toString().replaceAll('Exception: ', '')}",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFF78E91),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      body: Stack(
        children: [
          // Background Decorative Elements (Modern Subtle Gradient Shapes)
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F1).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isWideScreen ? 1000 : 450,
                      minHeight: isWideScreen ? 580 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isWideScreen ? _buildWideLayout() : _buildCompactLayout(),
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7EAC6D)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Sedang memproses...",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
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

  // DESAIN WIDE LAYOUT (SPLIT SCREEN UNTUK WINDOWS DESKTOP/WEB/TABLET)
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Panel Kiri: Maskot & Pesan Penyambut (55% lebar)
        Expanded(
          flex: 11,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF0F1), Color(0xFFE8F5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Efek Animasi Melayang untuk Maskot
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/mascot.png',
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Halo, Sahabat MORA! 👋",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Aku MORA-bot, siap membantumu mengelola rekam medis dan reservasi dengan bidan mandiri secara mudah dan profesional.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Lencana Fitur Kecil
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureBadge(Icons.security, "Aman & Privat"),
                    const SizedBox(width: 10),
                    _buildFeatureBadge(Icons.speed, "Cepat & Tepat"),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Panel Kanan: Logo & Formulir Login (45% lebar)
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo MORA Baru
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                _buildFormFields(),
                const SizedBox(height: 30),
                _buildFooterSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // DESAIN COMPACT LAYOUT (SATU KOLOM VERTIKAL UNTUK HP / LAYAR KECIL)
  Widget _buildCompactLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo MORA Baru di Atas
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 0),

          // Maskot Kecil Menyambut di bawah Logo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/mascot.png',
                  height: 55,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo! Aku Linky",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Yuk masuk untuk kelola janji temu dan catatan medis.",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Formulir Login
          _buildFormFields(),
          const SizedBox(height: 30),

          // Footer & Link Daftar
          _buildFooterSection(),
        ],
      ),
    );
  }

  // WIDGET KELOMPOK FORM INPUT
  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModernTextField(
          controller: _emailController,
          label: "ALAMAT EMAIL",
          hint: "Masukkan Email Anda",
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        _buildModernTextField(
          controller: _passwordController,
          label: "KATA SANDI",
          hint: "Masukkan kata sandi Anda",
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: const Color(0xFF7EAC6D),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        _buildOptionsRow(),
        const SizedBox(height: 24),
        _buildLoginButton(),
      ],
    );
  }

  // DESAIN INPUT FIELD MODERN
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A5568),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7F5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: type,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF2D3748),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.black26, fontSize: 13),
              prefixIcon: Icon(icon, color: const Color(0xFF7EAC6D), size: 20),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET CHECKBOX DAN LUPA SANDI
  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) => setState(() => _rememberMe = val ?? false),
                activeColor: const Color(0xFF7EAC6D),
                checkColor: Colors.white,
                side: const BorderSide(color: Colors.black26, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: Text(
                "Ingat saya",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showForgotPasswordDialog(context),
          child: Text(
            "Lupa kata sandi?",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFFF78E91),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // TOMBOL MASUK DENGAN GRADIEN PREMIUM
  Widget _buildLoginButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7EAC6D), Color(0xFF6B9C5A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7EAC6D).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          "MASUK",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  // FOOTER DAN LINK PENDAFTARAN
  Widget _buildFooterSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Belum punya akun? ",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45, fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: Text(
                "Daftar sekarang",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF7EAC6D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          "© 2026 MORA By Healink Technology",
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.black26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  // WIDGET PEMBANTU BADGE FITUR
  Widget _buildFeatureBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8F5E9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7EAC6D)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}
