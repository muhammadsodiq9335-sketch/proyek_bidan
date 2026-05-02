import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mock_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  bool isChecked = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Syarat & Ketentuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: const Text(
              '1. Layanan Kami\n'
              'Aplikasi ini menyediakan platform untuk mempermudah pemesanan layanan kesehatan ibu dan anak (Klinik & Home Care).\n\n'
              '2. Pendaftaran Akun\n'
              'Pasien diwajibkan memberikan data diri yang valid. Pasien bertanggung jawab atas keamanan akunnya.\n\n'
              '3. Reservasi & Jadwal\n'
              'Pemesanan bersifat estimasi waktu. Jadwal final bergantung konfirmasi Bidan. Untuk Home Care, Bidan berhak membatalkan jika lokasi tidak aman.\n\n'
              '4. Pembatalan\n'
              'Pembatalan maksimal 2 jam sebelum jadwal. Keterlambatan lebih dari 30 menit dapat menyebabkan pembatalan sepihak.\n\n'
              '5. Biaya & Pembayaran\n'
              'Harga yang tertera adalah estimasi. Pembayaran dilakukan setelah layanan selesai.\n\n'
              '6. Kerahasiaan Medis\n'
              'Seluruh data medis dan pribadi Anda dijaga kerahasiaannya sesuai standar etika kebidanan.',
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF00897B), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Daftar Akun Baru",
          style: TextStyle(
            color: Color(0xFF1B2E35),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Nama Lengkap"),
              _buildTextField(hint: "Masukkan nama lengkap sesuai KTP", icon: Icons.person_outline, keyboardType: TextInputType.name, controller: _namaController),
              const SizedBox(height: 16),
              
              _buildLabel("Tanggal Lahir"),
              _buildTextField(
                hint: "dd/mm/yyyy", 
                icon: Icons.calendar_today_outlined, 
                keyboardType: TextInputType.number,
                controller: _tglLahirController,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))],
                onIconTap: () => _selectDate(context),
              ),
              const SizedBox(height: 4),
              const Text(
                "* Usia akan dihitung otomatis",
                style: TextStyle(color: Color(0xFF00897B), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              _buildLabel("Alamat Lengkap"),
              _buildTextField(hint: "Masukkan alamat domisili", icon: null, maxLines: 3, keyboardType: TextInputType.streetAddress, controller: _alamatController),
              const SizedBox(height: 16),
              
              _buildLabel("Email atau No. HP"),
              _buildTextField(
                hint: "Masukkan email atau nomor HP aktif", 
                icon: Icons.contact_mail_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              _buildLabel("Kata Sandi"),
              _buildTextField(
                hint: "Kata sandi", 
                icon: Icons.lock_outline,
                isPassword: true,
                isObscure: !isPasswordVisible,
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                onVisibilityToggle: () {
                  setState(() => isPasswordVisible = !isPasswordVisible);
                }
              ),
              const SizedBox(height: 16),
              
              _buildLabel("Konfirmasi Kata Sandi"),
              _buildTextField(
                hint: "Konfirmasi kata sandi", 
                icon: Icons.verified_outlined,
                isPassword: true,
                isObscure: !isConfirmPasswordVisible,
                controller: _confirmPasswordController,
                keyboardType: TextInputType.visiblePassword,
                onVisibilityToggle: () {
                  setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible);
                }
              ),
              const SizedBox(height: 24),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: (val) {
                        setState(() => isChecked = val ?? false);
                      },
                      activeColor: const Color(0xFFAED581),
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text("Saya menyetujui ", style: TextStyle(color: Colors.black54, fontSize: 12)),
                        GestureDetector(
                          onTap: _showTermsDialog,
                          child: const Text(
                            "Syarat dan Ketentuan",
                            style: TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const Text(" serta ", style: TextStyle(color: Colors.black54, fontSize: 12)),
                        GestureDetector(
                          onTap: _showTermsDialog,
                          child: const Text(
                            "Kebijakan Privasi",
                            style: TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final confirmPassword = _confirmPasswordController.text.trim();
                    final nama = _namaController.text.trim();
                    final tglLahir = _tglLahirController.text.trim();
                    final alamat = _alamatController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Email dan Kata Sandi harus diisi!"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (password != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Kata sandi tidak cocok!"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (!isChecked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Anda harus menyetujui Syarat dan Ketentuan!"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (MockDatabase.registeredUsers.containsKey(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Email/HP sudah terdaftar!"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    MockDatabase.registeredUsers[email] = password;
                    MockDatabase.userProfiles[email] = UserProfile(
                      email: email,
                      nama: nama.isNotEmpty ? nama : "Pengguna Baru",
                      tglLahir: tglLahir,
                      alamat: alamat,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pendaftaran berhasil! Silakan login."),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );

                    Future.delayed(const Duration(seconds: 2), () {
                      if (!mounted) return;
                      Navigator.pop(context);
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Daftar Sekarang ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.person_add_alt_1, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? ", style: TextStyle(fontSize: 13, color: Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(fontSize: 13, color: Color(0xFF00897B), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF546E7A), fontSize: 13),
      ),
    );
  }

  Widget _buildTextField({
    required String hint, 
    required IconData? icon, 
    TextEditingController? controller,
    int maxLines = 1,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onVisibilityToggle,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onIconTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      obscureText: isObscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        prefixIcon: icon != null 
            ? (onIconTap != null 
                ? IconButton(icon: Icon(icon, color: Colors.black38, size: 20), onPressed: onIconTap)
                : Icon(icon, color: Colors.black38, size: 20))
            : null,
        suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(isObscure ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined, color: Colors.black38, size: 20),
                onPressed: onVisibilityToggle,
              ) 
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 12 : 16, horizontal: icon == null ? 16 : 0),
      ),
    );
  }
}
