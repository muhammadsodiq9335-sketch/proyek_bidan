import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class PengaturanAkunScreen extends StatefulWidget {
  const PengaturanAkunScreen({super.key});

  @override
  State<PengaturanAkunScreen> createState() => _PengaturanAkunScreenState();
}

class _PengaturanAkunScreenState extends State<PengaturanAkunScreen> {
  final AuthService _authService = AuthService();
  final SupabaseService _supabaseService = SupabaseService();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tglLahirController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (AuthService.currentUserProfile != null) {
      _namaController.text = AuthService.currentUserProfile!.nama;
      _alamatController.text = AuthService.currentUserProfile!.alamat;
      
      String tgl = AuthService.currentUserProfile!.tglLahir;
      if (tgl.contains('-')) {
        try {
          final parts = tgl.split('-');
          if (parts.length == 3) {
            _tglLahirController.text = "${parts[2]}/${parts[1]}/${parts[0]}";
          } else {
            _tglLahirController.text = tgl;
          }
        } catch (_) {
          _tglLahirController.text = tgl;
        }
      } else {
        _tglLahirController.text = tgl;
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null && AuthService.currentUserProfile != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await image.readAsBytes();
        final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        final publicUrl = await _supabaseService.uploadAvatar(
          userId: AuthService.currentUserProfile!.id,
          fileBytes: bytes,
          fileName: fileName,
        );

        if (publicUrl != null) {
          await _supabaseService.updateProfileFoto(
            AuthService.currentUserProfile!.id,
            publicUrl,
          );

          setState(() {
            AuthService.currentUserProfile = UserProfile(
              id: AuthService.currentUserProfile!.id,
              email: AuthService.currentUserProfile!.email,
              nama: AuthService.currentUserProfile!.nama,
              tglLahir: AuthService.currentUserProfile!.tglLahir,
              alamat: AuthService.currentUserProfile!.alamat,
              role: AuthService.currentUserProfile!.role,
              fotoUrl: publicUrl,
            );
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto profil berhasil diperbarui')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload foto: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
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
              primary: Color(0xFF00897B),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1B2E35),
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

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ganti Password', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  hintText: 'Minimal 6 karakter',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (passwordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password minimal 6 karakter')),
                        );
                        return;
                      }
                      if (passwordController.text != confirmController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Konfirmasi password tidak cocok')),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);
                      try {
                        await _authService.changePassword(passwordController.text);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password berhasil diubah')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          setDialogState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal mengubah password: $e')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2185B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isLoading ? 'Memproses...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Pengaturan Akun', style: TextStyle(color: Color(0xFF1B2E35), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF1B2E35)),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
          TextButton(
            onPressed: () async {
              if (AuthService.currentUserProfile != null) {
                try {
                  String formattedTgl = _tglLahirController.text;
                  if (formattedTgl.contains('/')) {
                    try {
                      final parts = formattedTgl.split('/');
                      if (parts.length == 3) {
                        formattedTgl = "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
                      }
                    } catch (_) {}
                  }

                  final updatedData = {
                    'nama': _namaController.text,
                    'alamat': _alamatController.text,
                    'tgl_lahir': formattedTgl,
                  };
                  
                  await SupabaseService().updateUserProfile(
                    AuthService.currentUserProfile!.id, 
                    updatedData
                  );

                  setState(() {
                    AuthService.currentUserProfile = UserProfile(
                      id: AuthService.currentUserProfile!.id,
                      email: AuthService.currentUserProfile!.email,
                      nama: _namaController.text,
                      tglLahir: formattedTgl,
                      alamat: _alamatController.text,
                      role: AuthService.currentUserProfile!.role,
                      fotoUrl: AuthService.currentUserProfile!.fotoUrl,
                    );
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil berhasil diperbarui')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal memperbarui profil: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Color(0xFF00897B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: AuthService.currentUserProfile?.fotoUrl != null && AuthService.currentUserProfile!.fotoUrl!.isNotEmpty
                        ? NetworkImage(AuthService.currentUserProfile!.fotoUrl!)
                        : null,
                    child: AuthService.currentUserProfile?.fotoUrl == null || AuthService.currentUserProfile!.fotoUrl!.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  if (_isUploading)
                    const Positioned.fill(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFF00897B), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Nama Lengkap', _namaController, Icons.person_outline),
            _buildTextField('Alamat', _alamatController, Icons.location_on_outlined),
            _buildDatePickerField('Tanggal Lahir', _tglLahirController, Icons.calendar_today_outlined),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showChangePasswordDialog,
                icon: const Icon(Icons.lock_outline),
                label: const Text('Ganti Password'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFFC2185B)),
                  foregroundColor: const Color(0xFFC2185B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
