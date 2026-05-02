import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'pilih_lokasi_screen.dart';

class ChatScreen extends StatefulWidget {
  final bool isAdmin;
  final String patientName;

  const ChatScreen({
    super.key,
    this.isAdmin = false,
    this.patientName = 'Chat Umum',
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _editingIndex;

  List<Map<String, dynamic>> get messages =>
      MockDatabase.chatRooms[widget.patientName] ?? [];

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

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final time = TimeOfDay.now().format(context);

    setState(() {
      MockDatabase.chatRooms.putIfAbsent(widget.patientName, () => []);

      if (_editingIndex != null) {
        // Mode edit
        MockDatabase.chatRooms[widget.patientName]![_editingIndex!]['text'] =
            _controller.text.trim();
        MockDatabase.chatRooms[widget.patientName]![_editingIndex!]['edited'] =
            true;
        _editingIndex = null;
      } else {
        MockDatabase.chatRooms[widget.patientName]!.add({
          'sender': widget.isAdmin ? 'admin' : 'user',
          'text': _controller.text.trim(),
          'time': time,
          'type': 'text',
        });
      }

      _controller.clear();
    });
    _scrollToBottom();
  }

  void _startEdit(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text =
          MockDatabase.chatRooms[widget.patientName]![index]['text'];
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
      _controller.clear();
    });
  }

  void deleteMessage(int index) {
    setState(() {
      MockDatabase.chatRooms[widget.patientName]!.removeAt(index);
    });
  }

  void _showMessageOptions(BuildContext context, int index, bool isMe) {
    if (!isMe) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF00897B)),
              title: const Text('Edit Pesan'),
              onTap: () {
                Navigator.pop(context);
                _startEdit(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Hapus Pesan',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                deleteMessage(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PilihLokasiScreen()),
    );
    if (result != null && result.isNotEmpty) {
      final time = TimeOfDay.now().format(context);
      setState(() {
        MockDatabase.chatRooms.putIfAbsent(widget.patientName, () => []);
        MockDatabase.chatRooms[widget.patientName]!.add({
          'sender': widget.isAdmin ? 'admin' : 'user',
          'text': result,
          'time': time,
          'type': 'location',
        });
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
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
        leading: widget.isAdmin
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          // Edit indicator
          if (_editingIndex != null)
            Container(
              color: const Color(0xFFE0F2F1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 16, color: Color(0xFF00897B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mengedit: ${MockDatabase.chatRooms[widget.patientName]![_editingIndex!]['text']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF00897B)),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelEdit,
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ],
              ),
            ),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = widget.isAdmin
                    ? msg['sender'] == 'admin'
                    : msg['sender'] == 'user';
                final isLocation = msg['type'] == 'location';

                return GestureDetector(
                  onLongPress: () => _showMessageOptions(context, index, isMe),
                  child: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
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
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 1)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (isLocation)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on,
                                    size: 16,
                                    color: isMe
                                        ? Colors.white70
                                        : const Color(0xFF00897B)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    msg['text'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              msg['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (msg['edited'] == true)
                                Text(
                                  'diedit · ',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isMe
                                        ? Colors.white54
                                        : Colors.black38,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              Text(
                                msg['time'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white60 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                // Tombol Lokasi
                GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        size: 20, color: Color(0xFF00897B)),
                  ),
                ),
                const SizedBox(width: 8),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: _editingIndex != null
                          ? 'Edit pesan...'
                          : 'Ketik pesan...',
                      hintStyle:
                          const TextStyle(fontSize: 13, color: Colors.black38),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Kirim
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send_rounded,
                        size: 20, color: Colors.white),
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