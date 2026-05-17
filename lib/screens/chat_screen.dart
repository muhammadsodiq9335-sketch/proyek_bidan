import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import 'pilih_lokasi_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final bool isAdmin;
  final String patientName;
  final String? receiverId; // ID tujuan chat

  const ChatScreen({
    super.key,
    this.isAdmin = false,
    this.patientName = 'Admin',
    this.receiverId,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SupabaseService _supabaseService = SupabaseService();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String? _dynamicReceiverId;

  @override
  void initState() {
    super.initState();
    _dynamicReceiverId = widget.receiverId;
    if (_dynamicReceiverId == null) {
      _fetchAdminId();
    }
  }

  Future<void> _fetchAdminId() async {
    final adminId = await _supabaseService.getFirstAdminId();
    if (mounted && adminId != null) {
      setState(() {
        _dynamicReceiverId = adminId;
      });
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      DateTime dt = DateTime.parse(timestamp.toString()).toLocal();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  DateTime? _parseDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    try {
      return DateTime.parse(timestamp.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return "Hari Ini";
    } else if (msgDate == yesterday) {
      return "Kemarin";
    } else {
      final listDays = ["", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
      final listMonths = [
        "", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
        "Juli", "Agustus", "September", "Oktober", "November", "Desember"
      ];
      
      final dayName = listDays[date.weekday];
      final monthName = listMonths[date.month];
      return "$dayName, ${date.day} $monthName ${date.year}";
    }
  }

  Widget _buildDateHeader(DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          _formatDateHeader(date),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF546E7A),
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final senderId = AuthService.currentUserProfile?.id;
    final receiverId = _dynamicReceiverId;

    if (senderId == null || receiverId == null) {
      String errorMsg = 'Gagal mengirim pesan.';
      if (senderId == null) {
        errorMsg = 'Profil Anda tidak ditemukan. Silakan login ulang.';
      } else if (receiverId == null) {
        errorMsg = 'Admin sedang tidak tersedia. Mohon coba lagi nanti.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      return;
    }

    try {
      await _supabaseService.sendMessage(senderId, receiverId, text);
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesan: $e')),
      );
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PilihLokasiScreen()),
    );
    if (result != null && result.isNotEmpty) {
      final senderId = AuthService.currentUserProfile?.id;
      final receiverId = _dynamicReceiverId;
      if (senderId == null || receiverId == null) return;
      
      try {
        await _supabaseService.sendMessage(senderId, receiverId, '[Lokasi] $result');
        _scrollToBottom();
      } catch (e) {
        print('Error sending location: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Bottom Sheet untuk pilih Kamera atau Galeri
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('Kirim Media', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1B2E35))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  color: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                _buildAttachmentOption(
                  icon: Icons.image_rounded,
                  label: 'Galeri',
                  color: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on_rounded,
                  label: 'Lokasi',
                  color: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFEF6C00),
                  onTap: () {
                    Navigator.pop(context);
                    _pickLocation();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
    
    if (image != null) {
      final senderId = AuthService.currentUserProfile?.id;
      final receiverId = _dynamicReceiverId;
      if (senderId == null || receiverId == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi berakhir, silakan login ulang.')));
        return;
      }

      setState(() => _isLoadingImage = true);

      try {
        final bytes = await image.readAsBytes();
        final url = await _supabaseService.uploadChatImage(
          senderId: senderId,
          fileBytes: bytes,
          fileName: image.name,
        );

        if (url != null) {
          await _supabaseService.sendMessage(senderId, receiverId, '[Gambar] $url');
          _scrollToBottom();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal mengunggah gambar. Pastikan Storage Supabase "chat_images" sudah dibuat.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoadingImage = false);
      }
    }
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1B2E35))),
        ],
      ),
    );
  }

  bool _isLoadingImage = false;

  void _showMessageOptions(Map<String, dynamic> msg, bool isLocation, bool isImage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isImage && !isLocation)
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Edit Pesan'),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(msg);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Pesan', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(msg['id'].toString());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editMessage(Map<String, dynamic> msg) {
    final TextEditingController editController = TextEditingController(text: msg['text']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Pesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: TextField(
            controller: editController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Ketik pesan baru...',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final newText = editController.text.trim();
                if (newText.isNotEmpty && newText != msg['text']) {
                  try {
                    await _supabaseService.updateChatMessage(msg['id'].toString(), newText);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengedit pesan: $e')));
                    }
                  }
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Pesan?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Text('Pesan ini akan dihapus untuk semua orang dalam obrolan ini.', style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                try {
                  await _supabaseService.deleteChatMessage(messageId);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus pesan: $e')));
                  }
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = AuthService.currentUserProfile?.id ?? '';
    final otherId = _dynamicReceiverId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
          onPressed: () {
            if (widget.isAdmin) {
              Navigator.of(context).pushNamedAndRemoveUntil('/admin_dashboard', (route) => false);
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
            }
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE0F2F1),
              child: const Icon(Icons.person, size: 18, color: Color(0xFF00897B)),
            ),
            const SizedBox(width: 10),
            Text(
              widget.patientName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2E35),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabaseService.getChatMessages(myId, otherId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('Belum ada pesan. Silakan mulai chat!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == myId;
                    final text = msg['text'] as String;
                    final isLocation = text.startsWith('[Lokasi]');
                    final isImage = text.startsWith('[Gambar]');
                    
                    final currentDt = _parseDateTime(msg['created_at']);
                    bool showDateHeader = false;
                    if (currentDt != null) {
                      if (index == messages.length - 1) {
                        showDateHeader = true;
                      } else {
                        final nextMsg = messages[index + 1];
                        final nextDt = _parseDateTime(nextMsg['created_at']);
                        if (nextDt != null) {
                          if (currentDt.year != nextDt.year ||
                              currentDt.month != nextDt.month ||
                              currentDt.day != nextDt.day) {
                            showDateHeader = true;
                          }
                        } else {
                          showDateHeader = true;
                        }
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDateHeader && currentDt != null)
                          _buildDateHeader(currentDt),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.72,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF00897B) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
                              ],
                            ),
                            child: GestureDetector(
                              onLongPress: isMe ? () => _showMessageOptions(msg, isLocation, isImage) : null,
                              onTap: isLocation ? () async {
                                final address = text.replaceFirst('📍 ', '').replaceFirst('[Lokasi] ', '');
                                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tidak dapat membuka peta')),
                                  );
                                }
                              } : null,
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (isLocation)
                                    Column(
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.location_on, size: 18, color: isMe ? Colors.white : const Color(0xFF00897B)),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'Lokasi Terbagi',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          text.replaceFirst('📍 ', '').replaceFirst('[Lokasi] ', ''),
                                          style: TextStyle(
                                            color: isMe ? Colors.white.withOpacity(0.9) : Colors.black87,
                                            fontSize: 12,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.map_outlined, size: 14, color: Colors.white),
                                              SizedBox(width: 6),
                                              Text('Lihat di Peta', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (isImage)
                                    Column(
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            text.replaceFirst('[Gambar] ', ''),
                                            width: 200,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                width: 200,
                                                height: 150,
                                                color: Colors.black12,
                                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 200,
                                              height: 150,
                                              color: Colors.black12,
                                              child: const Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    )
                                  else
                                    Text(
                                      text,
                                      style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13),
                                    ),
                                  const SizedBox(height: 4),
                                   Text(
                                    _formatTime(msg['created_at']),
                                    style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

              },
            ),
          ),

          // Input bar modern
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00897B), size: 28),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black38),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _isLoadingImage 
                  ? const Padding(padding: EdgeInsets.all(8), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                  : IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF00897B), size: 28),
                      onPressed: sendMessage,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}