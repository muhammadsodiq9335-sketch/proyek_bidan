import 'package:flutter/material.dart';
import '../mock_data.dart';

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

  List<Map<String, dynamic>> get messages =>
      MockDatabase.chatRooms[widget.patientName] ?? [];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final time = TimeOfDay.now().format(context);

    setState(() {
      MockDatabase.chatRooms.putIfAbsent(widget.patientName, () => []);

      MockDatabase.chatRooms[widget.patientName]!.add({
        'sender': widget.isAdmin ? 'admin' : 'user',
        'text': _controller.text,
        'time': time,
        'type': 'text',
      });

      _controller.clear();
    });
  }

  void deleteMessage(int index) {
    setState(() {
      MockDatabase.chatRooms[widget.patientName]!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: Text(widget.patientName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                final isMe = widget.isAdmin
                    ? msg['sender'] == 'admin'
                    : msg['sender'] == 'user';

                return GestureDetector(
                  onLongPress: isMe ? () => deleteMessage(index) : null,
                  child: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg['time'],
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// INPUT
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send, color: Colors.teal),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}