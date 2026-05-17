import 'package:flutter/material.dart';
import 'riwayat_reservasi_screen.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Future<List<Map<String, dynamic>>>? _notifFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifikasi();
  }

  void _refreshNotifikasi() {
    String? userId = AuthService.currentUserProfile?.id;
    if (userId == null) {
      final user = AuthService().getCurrentUser();
      userId = user?.id;
    }

    if (userId != null && userId.isNotEmpty) {
      final String currentId = userId;
      setState(() {
        _notifFuture = _supabaseService.getNotifikasi(currentId).then((list) {
          _supabaseService.markNotifikasiSebagaiDibaca(currentId);
          return list;
        });
      });
    } else {
      setState(() {
        _notifFuture = Future.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('Notifikasi',
            style: TextStyle(
                color: Color(0xFF1B2E35),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2E35)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1B2E35)),
            onPressed: () => _refreshNotifikasi(),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notifFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00897B)));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return InkWell(
                onTap: () => _handleNotifClick(context, notif),
                child: _buildNotifCard(notif),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotifClick(BuildContext context, Map<String, dynamic> notif) {
    final screen = notif['screen'];
    if (screen == 'riwayat') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RiwayatReservasiScreen()),
      );
    } else if (screen == 'artikel') {
      // Jika ada screen artikel, arahkan ke tab artikel di dashboard
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    // Tambahkan navigasi lain di sini jika diperlukan
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80, color: Colors.black12),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
                fontSize: 16,
                color: Colors.black38,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(Map<String, dynamic> notif) {
    // Mapping icon from DB (string/int) to IconData
    IconData getIcon(dynamic iconData) {
      if (iconData is int) return IconData(iconData, fontFamily: 'MaterialIcons');
      if (iconData is String) {
        if (iconData == 'calendar_today') return Icons.calendar_today;
        if (iconData == 'info') return Icons.info_outline;
        if (iconData == 'chat') return Icons.chat_bubble_outline;
        if (iconData == 'people') return Icons.people_outline;
        if (iconData == 'check_circle') return Icons.check_circle_outline;
      }
      return Icons.notifications_none;
    }

    // Format time from ISO to friendly string
    String formatTime(dynamic createdAt) {
      if (createdAt == null) return '';
      final dt = DateTime.tryParse(createdAt.toString());
      if (dt == null) return createdAt.toString();
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}j';
      return '${dt.day}/${dt.month}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            child: Icon(getIcon(notif['icon']),
                color: const Color(0xFF00897B), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Row(
                      children: [
                        Text(
                          notif['title'] ?? 'Notifikasi',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2E35)),
                        ),
                        if (notif['is_read'] == false) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatTime(notif['created_at']),
                      style: const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                const SizedBox(height: 4),
                Text(
                  notif['message'] ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
