import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/category/category.dart';
import 'package:persentasi_karya/user/home_berita/tampilan_isi_berita/tampilan%20isi%20berita.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final supabase = Supabase.instance.client;
  int selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  
  List<Map<String, dynamic>> _allBerita = [];
  bool _isLoading = true;
  Set<String> _readNewsIds = {};

  @override
  void initState() {
    super.initState();
    _fetchBerita();
    _loadReadHistory(); // Panggil fungsi untuk memuat riwayat baca
  }

  // --- AMBIL BERITA DARI SUPABASE ---
  Future<void> _fetchBerita() async {
    try {
      final response = await supabase.from('berita').select().order('created_at', ascending: false);
      setState(() {
        _allBerita = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi mengambil data dari memori lokal
Future<void> _loadReadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> history = prefs.getStringList('read_news_ids') ?? [];
  setState(() {
    _readNewsIds = history.toSet();
  });
}

// Fungsi menyimpan ID saat berita diklik
Future<void> _markAsRead(String newsId) async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _readNewsIds.add(newsId);
  });
  await prefs.setStringList('read_news_ids', _readNewsIds.toList());
}

  @override
  Widget build(BuildContext context) {
    String activeCategory = categories[selectedCategoryIndex];
    
    // Logika Pemfilteran secara Lokal dari Data Supabase yg ditarik
    List<Map<String, dynamic>> filteredData = _allBerita.where((item) {
      bool matchesCategory = activeCategory.toUpperCase() == "SEMUA" ||
          // Ubah 'kategori' menjadi 'category'
          (item['category']?.toString().toUpperCase() == activeCategory.toUpperCase());

      // Ubah 'judul' menjadi 'title' dan 'deskripsi' menjadi 'description'
      bool matchesSearch = (item['title']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (item['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/Logo.png",
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 70),
                    ),
                    Text(
                      "TOAK DIGITAL",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: const Color(0xFF970747),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari Berita Hari Ini',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryIndex = index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedCategoryIndex == index ? const Color(0xFF970747) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  color: selectedCategoryIndex == index ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredData.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          "Berita tidak ditemukan",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final berita = filteredData[index];
                        // Ambil ID dari data Supabase
                        final String newsId = berita['id']?.toString() ?? index.toString();
                        final bool isRead = _readNewsIds.contains(newsId);

                        return GestureDetector(
                          onTap: () {
                            _markAsRead(newsId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailBerita(data: berita),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            // CLIPANTIALIAS: Wajib ada untuk memotong semua isi
                            clipBehavior: Clip.antiAlias, 
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                            children: [
                              // 1. Konten Utama
                              // Gunakan Opacity atau ColorFiltered untuk meredupkan konten jika sudah dibaca
                              Opacity(
                                opacity: isRead ? 0.6 : 1.0, // Membuat konten agak pudar jika sudah dibaca
                                child: ColorFiltered(
                                  colorFilter: isRead 
                                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            berita['image'] ?? '',
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => 
                                                Container(height: 150, color: Colors.grey),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          berita['category'] ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF970747), 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Text(
                                          berita['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 18, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Text(
                                          berita['description'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 2. Overlay Abu-abu (Hanya jika isRead)
                              if (isRead)
                                Positioned.fill(
                                  child: Container(
                                    // Menggunakan warna hitam transparan tipis agar terlihat "disabled"
                                    color: Colors.black.withOpacity(0.05), 
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}