import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  bool isChecked = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    _floatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _tglLahirController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7EAC6D),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2C3E50),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7EAC6D),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tglLahirController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined, color: Color(0xFF7EAC6D), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Syarat & Ketentuan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTermItem('1. Layanan Kami', 'Aplikasi ini menyediakan platform untuk mempermudah pemesanan layanan kesehatan ibu dan anak (Klinik & Home Care).'),
                _buildTermItem('2. Pendaftaran Akun', 'Pasien diwajibkan memberikan data diri yang valid. Pasien bertanggung jawab atas keamanan akunnya.'),
                _buildTermItem('3. Reservasi & Jadwal', 'Pemesanan bersifat estimasi waktu. Jadwal final bergantung konfirmasi Bidan. Untuk Home Care, Bidan berhak membatalkan jika lokasi tidak aman.'),
                _buildTermItem('4. Pembatalan', 'Pembatalan maksimal 2 jam sebelum jadwal. Keterlambatan lebih dari 30 menit dapat menyebabkan pembatalan sepihak.'),
                _buildTermItem('5. Biaya & Pembayaran', 'Harga yang tertera adalah estimasi. Pembayaran dilakukan setelah layanan selesai.'),
                _buildTermItem('6. Kerahasiaan Medis', 'Seluruh data medis dan pribadi Anda dijaga kerahasiaannya sesuai standar etika kebidanan.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Saya Mengerti',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF7EAC6D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final nama = _namaController.text.trim();
    final tglLahir = _tglLahirController.text.trim();
    final alamat = _alamatController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email dan Kata Sandi harus diisi!", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFF78E91),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kata sandi tidak cocok!", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFF78E91),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kata sandi harus terdiri dari minimal 6 karakter!", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFF78E91),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anda harus menyetujui Syarat dan Ketentuan!", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFF78E91),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = AuthService();

    try {
      // Format tglLahir ke YYYY-MM-DD untuk database
      String formattedTgl = "";
      if (tglLahir.isNotEmpty && tglLahir.contains('/')) {
        try {
          final parts = tglLahir.split('/');
          if (parts.length == 3) {
            formattedTgl = "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
          }
        } catch (_) {
          formattedTgl = tglLahir;
        }
      } else {
        formattedTgl = tglLahir;
      }

      await authService.signUp(
        email: email,
        password: password,
        nama: nama.isNotEmpty ? nama : "Pengguna Baru",
        tglLahir: formattedTgl,
        alamat: alamat,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pendaftaran berhasil! Silakan login.", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF7EAC6D),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mendaftar: ${e.toString()}", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFF78E91),
          behavior: SnackBarBehavior.floating,
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
                      maxWidth: isWideScreen ? 1100 : 450,
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
                      "Sedang memproses pendaftaran...",
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

  // DESAIN WIDE LAYOUT (SPLIT SCREEN UNTUK DESKTOP/WEB/TABLET)
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel Kiri: Maskot & Pesan Penyambut (50% lebar)
        Expanded(
          flex: 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 780),
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
                  "Gabung Bersama Kami! 🌸",
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
                    "Buat akun baru sekarang untuk memulai konsultasi bidan, mencatat rekam medis Anda, dan menjadwalkan kunjungan klinik atau home care dengan bidan mandiri terpercaya.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Lencana Fitur Kecil
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureBadge(Icons.health_and_safety, "Kesehatan Terpantau"),
                    const SizedBox(width: 10),
                    _buildFeatureBadge(Icons.event_available, "Pemesanan Mudah"),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Panel Kanan: Logo & Formulir Registrasi (50% lebar)
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF7EAC6D)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Logo MORA Baru
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Daftar Akun Baru",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFormFields(),
                const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF7EAC6D)),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          // Logo MORA Baru di Atas
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Daftar Akun Baru",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 24),

          // Formulir Registrasi
          _buildFormFields(),
          const SizedBox(height: 24),

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
          controller: _namaController,
          label: "NAMA LENGKAP",
          hint: "Masukkan nama lengkap sesuai KTP",
          icon: Icons.person_outline_rounded,
          type: TextInputType.name,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _tglLahirController,
          label: "TANGGAL LAHIR",
          hint: "dd/mm/yyyy",
          icon: Icons.calendar_today_outlined,
          type: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))],
          onIconTap: () => _selectDate(context),
          readOnly: true,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            "* Usia akan dihitung secara otomatis oleh sistem",
            style: GoogleFonts.poppins(color: const Color(0xFF7EAC6D), fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _alamatController,
          label: "ALAMAT LENGKAP DOMISILI",
          hint: "Masukkan alamat lengkap Anda",
          icon: Icons.home_outlined,
          maxLines: 2,
          type: TextInputType.streetAddress,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _emailController,
          label: "EMAIL ATAU NO. HP AKTIF",
          hint: "Masukkan alamat email atau nomor handphone aktif",
          icon: Icons.contact_mail_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _passwordController,
          label: "KATA SANDI",
          hint: "Minimal 6 karakter",
          icon: Icons.lock_outline_rounded,
          obscure: !isPasswordVisible,
          type: TextInputType.visiblePassword,
          suffix: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: const Color(0xFF7EAC6D),
            ),
            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
          ),
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _confirmPasswordController,
          label: "KONFIRMASI KATA SANDI",
          hint: "Ketik ulang kata sandi Anda",
          icon: Icons.verified_outlined,
          obscure: !isConfirmPasswordVisible,
          type: TextInputType.visiblePassword,
          suffix: IconButton(
            icon: Icon(
              isConfirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: const Color(0xFF7EAC6D),
            ),
            onPressed: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
          ),
        ),
        const SizedBox(height: 20),
        _buildTermsCheckboxRow(),
        const SizedBox(height: 24),
        _buildRegisterButton(),
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
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onIconTap,
    bool readOnly = false,
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
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: type,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: readOnly ? onIconTap : null,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF2D3748),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.black26, fontSize: 13),
              prefixIcon: onIconTap != null && !readOnly
                  ? IconButton(icon: Icon(icon, color: const Color(0xFF7EAC6D), size: 20), onPressed: onIconTap)
                  : Icon(icon, color: const Color(0xFF7EAC6D), size: 20),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET CHECKBOX PERSETUJUAN SYARAT KETENTUAN
  Widget _buildTermsCheckboxRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: isChecked,
            onChanged: (val) => setState(() => isChecked = val ?? false),
            activeColor: const Color(0xFF7EAC6D),
            checkColor: Colors.white,
            side: const BorderSide(color: Colors.black26, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54, height: 1.5),
              children: [
                const TextSpan(text: "Saya menyetujui "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: _showTermsDialog,
                    child: Text(
                      "Syarat & Ketentuan",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF7EAC6D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: " serta "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: _showTermsDialog,
                    child: Text(
                      "Kebijakan Privasi",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF7EAC6D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: " MORA."),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TOMBOL DAFTAR DENGAN GRADIEN PREMIUM
  Widget _buildRegisterButton() {
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
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          "DAFTAR SEKARANG",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  // FOOTER DAN LINK LOGIN
  Widget _buildFooterSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sudah memiliki akun? ",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45, fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                "Masuk di sini",
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
          "© 2026 MORA Bidan Mandiri",
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
