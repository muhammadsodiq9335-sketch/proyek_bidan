import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'chat_screen.dart';

// 🔥 IMPORT TANPA BENTROK
import 'admin_dashboard_screen.dart';
import 'admin_jadwal_screen.dart';
import 'admin_pasien_screen.dart';
import 'admin_pengaturan_screen.dart';

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

      bottomNavigationBar: _bottomNav(context, 2),
    );
  }

  Widget _bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,

      selectedItemColor: const Color(0xFF00897B),
      unselectedItemColor: Colors.grey,

      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminDashboardScreen()),
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminJadwalScreen()),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminChatListScreen()),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminPasienScreen()),
            );
            break;

          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminPengaturanScreen()),
            );
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Pembayaran"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}