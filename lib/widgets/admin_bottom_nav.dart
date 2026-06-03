import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AdminBottomNav extends StatefulWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
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
          .channel('admin_chat_notif_$_userId')
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

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFC2185B),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == widget.currentIndex) {
          // If already on Chat tab, just mark read
          if (index == 2) {
            _markChatAsRead();
          }
          return;
        }

        if (index == 2) {
           _markChatAsRead();
        }

        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/admin_jadwal');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/admin_chat_list');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/admin_pembayaran');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/admin_pengaturan');
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
        const BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Jadwal"),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: _unreadChatCount > 0,
            label: Text(_unreadChatCount.toString()),
            backgroundColor: Colors.red,
            child: const Icon(Icons.chat),
          ),
          label: "Chat",
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Pembayaran"),
        const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Pengaturan"),
      ],
    );
  }
}
