import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pilih_lokasi_screen.dart';

class ChatScreen extends StatefulWidget {
  final bool isAdmin;
  const ChatScreen({super.key, this.isAdmin = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  int? _editingIndex;

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final now = DateTime.now();
    final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    setState(() {
      if (_editingIndex != null) {
        MockDatabase.chatMessages[_editingIndex!]['text'] = _messageController.text.trim();
        MockDatabase.chatMessages[_editingIndex!]['time'] = "$timeString (diedit)";
        MockDatabase.chatMessages[_editingIndex!]['type'] = 'text'; // pastikan text
        _editingIndex = null;
      } else {
        MockDatabase.chatMessages.add({
          'sender': widget.isAdmin ? 'admin' : 'user',
          'text': _messageController.text.trim(),
          'time': timeString,
          'type': 'text',
        });
      }
      _messageController.clear();
    });
  }

  void _shareLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PilihLokasiScreen()),
    );

    // Jika user menekan konfirmasi dan mengembalikan string lokasi
    if (result != null && result is String) {
      final now = DateTime.now();
      final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      setState(() {
        MockDatabase.chatMessages.add({
          'sender': widget.isAdmin ? 'admin' : 'user',
          'text': result,
          'time': timeString,
          'type': 'location',
        });
      });
    }
  }

  void _deleteMessage(int index) {
    setState(() {
      MockDatabase.chatMessages.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
        _messageController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: widget.isAdmin ? _buildAdminAppBar(context) : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.isAdmin) _buildPatientHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: MockDatabase.chatMessages.length,
                itemBuilder: (context, index) {
                  final message = MockDatabase.chatMessages[index];
                  final isMe = widget.isAdmin
                      ? message['sender'] == 'admin'
                      : message['sender'] == 'user';
                  return _buildMessageBubble(message, isMe, index);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAdminAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Chat dengan Pasien',
        style: TextStyle(
          color: Color(0xFF1B2E35),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE0F2F1),
            child: Icon(Icons.support_agent, color: Color(0xFF00897B)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Care / Bidan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1B2E35),
                  ),
                ),
                Text(
                  'Online - Siap membantu Anda',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00897B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, int index) {
    final bool isLocation = message['type'] == 'location';
    // Mencegah edit untuk tipe lokasi
    final Function()? onLongPressAction = isMe
        ? () => _showMessageOptions(context, index, message['text'], isLocation)
        : null;

    return GestureDetector(
      onLongPress: onLongPressAction,
      onTap: isLocation
          ? () async {
              const urlStr = 'https://www.google.com/maps/search/?api=1&query=-6.200000,106.816666';
              final Uri url = Uri.parse(urlStr);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal membuka peta!')),
                  );
                }
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 16, color: Colors.grey),
              ),
            if (!isMe) const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF00897B) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (isLocation)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: 120,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://i.ibb.co/3W6qWvW/maps-placeholder.png', // Placeholder peta
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.location_on, color: Colors.red, size: 36),
                        ),
                      ),
                    Text(
                      message['text'],
                      style: TextStyle(
                        fontSize: 13,
                        color: isMe ? Colors.white : const Color(0xFF1B2E35),
                        fontWeight: isLocation ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['time'],
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) const SizedBox(width: 8),
            if (isMe)
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE0F2F1),
                child: Icon(Icons.person, size: 16, color: Color(0xFF00897B)),
              ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, int index, String currentText, bool isLocation) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLocation)
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Edit Pesan'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _editingIndex = index;
                      _messageController.text = currentText;
                    });
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Pesan'),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMessage(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_editingIndex != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 12, color: Colors.blue),
                  const SizedBox(width: 4),
                  const Text('Mengedit pesan', style: TextStyle(fontSize: 12, color: Colors.blue)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _editingIndex = null;
                        _messageController.clear();
                      });
                    },
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: _shareLocation,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: Color(0xFF00897B), size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _editingIndex != null ? 'Edit pesan...' : 'Ketik pesan...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00897B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _editingIndex != null ? Icons.check : Icons.send, 
                    color: Colors.white, 
                    size: 18
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
