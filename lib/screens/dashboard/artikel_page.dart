import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/artikel_pdf.dart';
import '../../services/supabase_service.dart';

class ArtikelPage extends StatefulWidget {
  const ArtikelPage({super.key});

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<ArtikelPdf>> _articlesFuture;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _articlesFuture = _supabaseService.getArtikelPdf();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isSearching)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Artikel Kesehatan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2E35),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: "Cari artikel...",
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search, color: const Color(0xFF546E7A)),
                  onPressed: () {
                    setState(() {
                      if (_isSearching) {
                        _isSearching = false;
                        _searchController.clear();
                        _searchQuery = "";
                      } else {
                        _isSearching = true;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ArtikelPdf>>(
              future: _articlesFuture,
              builder: (context, snapshot) {
                final isLoading = snapshot.connectionState == ConnectionState.waiting;

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var articles = snapshot.data ?? [];

                if (_searchQuery.isNotEmpty) {
                  articles = articles.where((article) => 
                    article.namaFile.toLowerCase().contains(_searchQuery)
                  ).toList();
                }

                if (articles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 64, color: Colors.black26),
                        SizedBox(height: 16),
                        Text("Belum ada artikel edukasi.", style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    final date = article.tanggalUpload;
                    final dateString = "${date.day}/${date.month}/${date.year}";

                    return GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(article.urlPdf);
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Tidak dapat membuka link")),
                            );
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF00897B).withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 5))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header dengan Gradient & Judul Singkat
                            Container(
                              height: 140,
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -10,
                                    bottom: -10,
                                    child: Icon(
                                      Icons.format_quote_rounded,
                                      size: 80,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      article.namaFile,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF00695C),
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00897B).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "KEMENKES RI",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF00897B),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        dateString,
                                        style: const TextStyle(
                                            fontSize: 11, 
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black38),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Baca panduan kesehatan resmi dan terpercaya untuk Bunda dan si kecil.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: const [
                                      Text(
                                        "Baca Selengkapnya",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF00897B)),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
