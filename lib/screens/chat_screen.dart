import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import 'pilih_lokasi_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final senderId = AuthService.currentUserProfile?.id;
    final receiverId = _dynamicReceiverId;

    if (senderId == null || receiverId == null) {
      if (receiverId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID Admin belum ditemukan. Mohon tunggu...')),
        );
      }
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final messages = snapshot.data ?? [];
                
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
                    
                    return Align(
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
                              else
                                Text(
                                  text,
                                  style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Baru saja',
                                style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF00897B)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}