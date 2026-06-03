import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'dashboard/beranda_page.dart';
import 'dashboard/reservasi_page.dart';
import 'dashboard/artikel_page.dart';
import 'dashboard/profil_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _unreadChatCount = 0;
  var _chatSubscription;
  RealtimeChannel? _chatNotifChannel;
  String? _userId;
  DateTime _lastReadTime = DateTime.parse('2000-01-01T00:00:00.000Z');
  DateTime? _latestMessageTime;

  @override
  void initState() {
    super.initState();
    _initUnreadListener();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _chatNotifChannel?.unsubscribe();
    super.dispose();
  }

  void _initUnreadListener() async {
    final user = AuthService().getCurrentUser();
    _userId = user?.id;
    if (_userId != null) {
      final prefs = await SharedPreferences.getInstance();
      String? lastReadStr = prefs.getString('last_read_chat_$_userId');
      if (lastReadStr == null) {
        // Jika login pertama kali, anggap semua chat lama sudah terbaca
        lastReadStr = DateTime.now().toUtc().toIso8601String();
        await prefs.setString('last_read_chat_$_userId', lastReadStr);
      }
      _lastReadTime = DateTime.parse(lastReadStr);

      _chatSubscription = Supabase.instance.client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .listen((data) {
        if (!mounted) return;
        int count = 0;
        DateTime maxDt = _lastReadTime;
        for (var msg in data) {
          if (msg['receiver_id'] == _userId) {
            final dt = DateTime.parse(msg['created_at']);
            if (dt.isAfter(maxDt)) {
              maxDt = dt;
            }
            if (dt.isAfter(_lastReadTime)) {
              count++;
            }
          }
        }
        _latestMessageTime = maxDt;
        setState(() {
          _unreadChatCount = count;
        });
      });

      _chatNotifChannel = Supabase.instance.client
          .channel('chat_notif_$_userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'receiver_id',
              value: _userId,
            ),
            callback: (payload) async {
              if (mounted) {
                await NotificationService().notify();
              }
            },
          )
          .subscribe();
    }
  }

  void _markChatAsRead() async {
    if (_userId != null) {
      final prefs = await SharedPreferences.getInstance();
      final timeToSave = _latestMessageTime ?? DateTime.now().toUtc();
      final now = timeToSave.add(const Duration(milliseconds: 1));
      await prefs.setString('last_read_chat_$_userId', now.toIso8601String());
      _lastReadTime = now;
      setState(() {
        _unreadChatCount = 0;
      });
    }
  }

  // Menggunakan IndexedStack untuk menjaga state halaman
  // sehingga tidak reload setiap pindah tab
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BerandaPage(
            onTabChange: (index) => setState(() => _currentIndex = index),
          ),
          const ReservasiPage(),
          ChatScreen(),
          const ArtikelPage(),
          const ProfilPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 2) {
              _markChatAsRead();
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: const Color(0xFFB0BEC5),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.5,
        ),
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'DASHBOARD',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'RESERVASI',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _unreadChatCount > 0,
              label: Text(_unreadChatCount.toString()),
              backgroundColor: Colors.red,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: const Icon(Icons.chat_bubble),
            label: 'CHAT',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'ARTIKEL',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFIL',
          ),
        ],
      ),
    );
  }
}
