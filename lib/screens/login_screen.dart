import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_reset, color: Color(0xFF00897B)),
            SizedBox(width: 8),
            Text('Lupa Kata Sandi', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan email terdaftar Anda. Kami akan mengirimkan informasi pemulihan kata sandi.',
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.black38, size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fungsi ini akan segera hadir.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Kirim'),
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
        const SnackBar(
          content: Text("Email dan Kata Sandi harus diisi!"),
          backgroundColor: Colors.redAccent,
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
          content: Text("Login gagal: ${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(color: const Color(0xFFE0F2F1), shape: BoxShape.circle),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 50),
                      _buildLoginForm(),
                      const SizedBox(height: 40),
                      _buildFooterLinks(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF00897B))),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.health_and_safety_rounded, size: 60, color: Color(0xFF00897B)),
        ),
        const SizedBox(height: 24),
        const Text(
          "MORA",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 6, color: Color(0xFF1B2E35)),
        ),
        const SizedBox(height: 12),
        const Text(
          "Silakan masuk dengan akun Anda",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black45, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _emailController,
          label: "EMAIL",
          hint: "admin@bidan.com atau email pasien",
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _passwordController,
          label: "KATA SANDI",
          hint: "••••••••",
          icon: Icons.lock_open_rounded,
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.black38),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        _buildOptionsRow(),
        const SizedBox(height: 32),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildTextField({
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
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black12, fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF00897B), size: 22),
            suffixIcon: suffix,
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEEEEEE), width: 2)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00897B), width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24, width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) => setState(() => _rememberMe = val ?? false),
                activeColor: const Color(0xFF00897B),
                side: const BorderSide(color: Colors.black12, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            const Text("Ingat saya", style: TextStyle(fontSize: 13, color: Colors.black45)),
          ],
        ),
        GestureDetector(
          onTap: () => _showForgotPasswordDialog(context),
          child: const Text(
            "Lupa kata sandi?",
            style: TextStyle(fontSize: 13, color: Color(0xFF00897B), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: const Color(0xFF00897B).withOpacity(0.4),
      ),
      child: const Text(
        "MASUK",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Belum punya akun? ", style: TextStyle(fontSize: 14, color: Colors.black45)),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
              },
              child: const Text(
                "Daftar sekarang",
                style: TextStyle(fontSize: 14, color: Color(0xFF00897B), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Text(
          "© 2026 MORA Bidan Mandiri",
          style: TextStyle(fontSize: 11, color: Colors.black12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }
}
