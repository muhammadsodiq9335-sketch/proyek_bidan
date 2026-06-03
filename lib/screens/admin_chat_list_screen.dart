import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../widgets/admin_bottom_nav.dart';
import 'chat_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});
  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  // patientId -> last message info
  Map<String, Map<String, dynamic>> _lastMessages = {};
  // patientId -> unread count
  Map<String, int> _unreadCounts = {};
  bool _isLoading = true;
  String? _adminId;
  RealtimeChannel? _chatChannel;
  final TextEditingController _searchController = TextEditingController();

  static const _bgScaffold = Color(0xFFFCE4EC);
  static const _textPrimary = Color(0xFF1B2E35);
  static const _textSecondary = Color(0xFF607D8B);
  static const _accent = Color(0xFFC2185B);
  static const _cardShadow = [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3))];

  @override
  void initState() {
    super.initState();
    _adminId = AuthService().getCurrentUser()?.id;
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    try {
      final patients = await _supabaseService.getAllUserProfiles(role: 'pasien');
      if (!mounted) return;
      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
      await _loadLastMessages();
      _subscribeRealtime();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLastMessages() async {
    if (_adminId == null) return;
    final prefs = await SharedPreferences.getInstance();

    final Map<String, Map<String, dynamic>> lastMsgs = {};
    final Map<String, int> unreadMap = {};

    for (final patient in _allPatients) {
      final patientId = patient['id'] as String?;
      if (patientId == null) continue;

      final lastReadStr = prefs.getString('last_read_chat_${_adminId}_$patientId') ??
          prefs.getString('last_read_chat_$_adminId') ??
          '2000-01-01T00:00:00.000Z';
      final lastReadTime = DateTime.parse(lastReadStr);

      try {
        // Ambil pesan terakhir antara admin dan pasien ini
        final messages = await Supabase.instance.client
            .from('chat_messages')
            .select()
            .or('and(sender_id.eq.$patientId,receiver_id.eq.$_adminId),and(sender_id.eq.$_adminId,receiver_id.eq.$patientId)')
            .order('created_at', ascending: false)
            .limit(20);

        if (messages.isNotEmpty) {
          final last = messages.first;
          lastMsgs[patientId] = {
            'text': last['text'] ?? last['image_url'] != null ? '📷 Foto' : '',
            'created_at': last['created_at'],
            'sender_id': last['sender_id'],
          };

          // Hitung unread: pesan dari pasien ke admin yang setelah lastRead
          int unread = 0;
          for (final msg in messages) {
            if (msg['sender_id'] == patientId && msg['receiver_id'] == _adminId) {
              final dt = DateTime.parse(msg['created_at']);
              if (dt.isAfter(lastReadTime)) unread++;
            }
          }
          unreadMap[patientId] = unread;
        } else {
          lastMsgs[patientId] = {};
          unreadMap[patientId] = 0;
        }
      } catch (_) {
        lastMsgs[patientId] = {};
        unreadMap[patientId] = 0;
      }
    }

    if (mounted) {
      setState(() {
        _lastMessages = lastMsgs;
        _unreadCounts = unreadMap;
        // Urutkan: yang ada unread duluan, lalu berdasarkan waktu pesan terakhir
        _sortPatients();
      });
    }
  }

  void _sortPatients() {
    _filteredPatients.sort((a, b) {
      final aId = a['id'] as String? ?? '';
      final bId = b['id'] as String? ?? '';
      final aUnread = _unreadCounts[aId] ?? 0;
      final bUnread = _unreadCounts[bId] ?? 0;
      if (aUnread != bUnread) return bUnread.compareTo(aUnread); // unread duluan
      final aTime = _lastMessages[aId]?['created_at'] as String? ?? '';
      final bTime = _lastMessages[bId]?['created_at'] as String? ?? '';
      return bTime.compareTo(aTime); // terbaru duluan
    });
    _allPatients.sort((a, b) {
      final aId = a['id'] as String? ?? '';
      final bId = b['id'] as String? ?? '';
      final aUnread = _unreadCounts[aId] ?? 0;
      final bUnread = _unreadCounts[bId] ?? 0;
      if (aUnread != bUnread) return bUnread.compareTo(aUnread);
      final aTime = _lastMessages[aId]?['created_at'] as String? ?? '';
      final bTime = _lastMessages[bId]?['created_at'] as String? ?? '';
      return bTime.compareTo(aTime);
    });
  }

  void _subscribeRealtime() {
    if (_adminId == null) return;
    _chatChannel = Supabase.instance.client
        .channel('admin_chatlist_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) async {
            final msg = payload.newRecord;
            final senderId = msg['sender_id'] as String?;
            final receiverId = msg['receiver_id'] as String?;
            // Update hanya jika pesan ini melibatkan admin
            if (senderId == _adminId || receiverId == _adminId) {
              await _loadLastMessages();
            }
          },
        )
        .subscribe();
  }

  Future<void> _markPatientChatAsRead(String patientId) async {
    if (_adminId == null) return;
    final prefs = await SharedPreferences.getInstance();
    // Simpan per-pasien agar tiap konversasi punya waktu baca sendiri
    final lastMsg = _lastMessages[patientId];
    final timeToSave = lastMsg != null && lastMsg['created_at'] != null
        ? DateTime.parse(lastMsg['created_at']).add(const Duration(milliseconds: 1))
        : DateTime.now().toUtc();
    await prefs.setString(
        'last_read_chat_${_adminId}_$patientId', timeToSave.toIso8601String());
    if (mounted) {
      setState(() => _unreadCounts[patientId] = 0);
    }
  }

  void _filterPatients(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPatients = List.from(_allPatients);
        _sortPatients();
      });
      return;
    }
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredPatients = _allPatients.where((patient) {
        final name = (patient['nama'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    });
  }

  String _formatTime(String? isoStr) {
    if (isoStr == null) return '';
    try {
      final dt = DateTime.parse(isoStr).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        // Hari ini: tampilkan jam
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      } else {
        // Hari lain: tampilkan tanggal
        final d = dt.day.toString().padLeft(2, '0');
        final mo = dt.month.toString().padLeft(2, '0');
        return '$d/$mo';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text("Chat Pasien",
            style: TextStyle(
                color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        foregroundColor: _textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterPatients,
                    decoration: InputDecoration(
                      hintText: 'Cari nama pasien...',
                      prefixIcon: const Icon(Icons.search, color: _textSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredPatients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 56, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text("Pasien tidak ditemukan",
                                  style: TextStyle(color: _textSecondary)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadLastMessages,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = _filteredPatients[index];
                              final name = patient['nama'] ?? 'Pasien';
                              final patientId = patient['id'] as String?;
                              final initial = name.toString().isNotEmpty
                                  ? name.toString()[0].toUpperCase()
                                  : '?';
                              final lastMsg = patientId != null
                                  ? _lastMessages[patientId]
                                  : null;
                              final unread = patientId != null
                                  ? (_unreadCounts[patientId] ?? 0)
                                  : 0;
                              final lastText = lastMsg?['text'] as String? ?? '';
                              final lastTime = lastMsg?['created_at'] as String?;
                              final lastSender = lastMsg?['sender_id'] as String?;
                              final isOutgoing = lastSender == _adminId;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: _cardShadow,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFFFF0F5),
                                        ),
                                        child: ClipOval(
                                          child: (patient['foto_url'] != null &&
                                                  patient['foto_url']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? Image.network(
                                                  patient['foto_url'].toString(),
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (context, error,
                                                              stackTrace) =>
                                                          Center(
                                                            child: Text(
                                                              initial,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: _accent,
                                                                  fontSize: 18),
                                                            ),
                                                          ),
                                                )
                                              : Center(
                                                  child: Text(
                                                    initial,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: _accent,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      // Dot indikator unread
                                      if (unread > 0)
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: _accent,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5),
                                            ),
                                            constraints: const BoxConstraints(
                                                minWidth: 18, minHeight: 18),
                                            child: Center(
                                              child: Text(
                                                unread > 9 ? '9+' : '$unread',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                              fontWeight: unread > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              color: _textPrimary,
                                              fontSize: 14),
                                        ),
                                      ),
                                      if (lastTime != null)
                                        Text(
                                          _formatTime(lastTime),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: unread > 0
                                                  ? _accent
                                                  : _textSecondary,
                                              fontWeight: unread > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal),
                                        ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Row(
                                      children: [
                                        if (isOutgoing)
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(right: 3),
                                            child: Icon(Icons.reply,
                                                size: 13,
                                                color: _textSecondary),
                                          ),
                                        Expanded(
                                          child: Text(
                                            lastText.isEmpty
                                                ? 'Belum ada pesan'
                                                : lastText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: unread > 0
                                                  ? _textPrimary
                                                  : _textSecondary,
                                              fontWeight: unread > 0
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    if (patientId != null) {
                                      await _markPatientChatAsRead(patientId);
                                    }
                                    if (!mounted) return;
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          isAdmin: true,
                                          patientName: name,
                                          receiverId: patientId,
                                        ),
                                      ),
                                    );
                                    // Refresh saat kembali dari chat
                                    if (mounted) await _loadLastMessages();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}
