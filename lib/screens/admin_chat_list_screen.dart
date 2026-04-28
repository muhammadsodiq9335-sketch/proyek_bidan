import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'chat_screen.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = MockDatabase.chatRooms.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text("Chat Pasien"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final name = patients[index];
          final messages = MockDatabase.chatRooms[name]!;

          final lastMessage = messages.isNotEmpty
              ? messages.last['text']
              : "Belum ada pesan";

          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(name),
            subtitle: Text(lastMessage),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    isAdmin: true,
                    patientName: name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}