import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/category/category.dart';
import 'package:persentasi_karya/category/data.dart';
import 'package:persentasi_karya/user/home%20berita/tampilan_isi_berita/tampilan%20isi%20berita.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    String activeCategory = categories[selectedCategoryIndex];
   List<Map<String, String>> filteredData = culinaryData.where((item) {
      // Filter Kategori
      bool matchesCategory = activeCategory.toUpperCase() == "SEMUA" ||
          item['category'] == activeCategory.toUpperCase();

      // Filter Pencarian (berdasarkan judul atau deskripsi)
      bool matchesSearch = item['title']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item['description']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

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
                SizedBox(height: 20),
                filteredData.isEmpty
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
                    return GestureDetector(
                      onTap: () {
                        // Fungsi untuk berpindah halaman sambil membawa data berita yang diklik
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailBerita(data: filteredData[index]),),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  filteredData[index]['image']!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                filteredData[index]['category']!,
                                style: const TextStyle(color: Color(0xFF970747), fontWeight: FontWeight.bold),
                              ),
                              Text(
                                filteredData[index]['title']!,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                filteredData[index]['description']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
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