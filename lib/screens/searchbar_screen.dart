import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicv_project/screens/detail_screen.dart';
import 'package:comicv_project/widgets/widget_support.dart';

class SearchBarScreen extends StatefulWidget {
  const SearchBarScreen({super.key});

  @override
  State<SearchBarScreen> createState() => _SearchBarScreenState();
}

class _SearchBarScreenState extends State<SearchBarScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<QueryDocumentSnapshot> _allProducts = [];
  List<QueryDocumentSnapshot> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  void _loadAllProducts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('posts').get();

      setState(() {
        _allProducts = snapshot.docs;
      });

      print('Loaded ${_allProducts.length} products from Firestore');

      for (int i = 0; i < _allProducts.length && i < 3; i++) {
        print('Product $i title: ${_allProducts[i]['title']}');
      }
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
      _isSearching = _searchQuery.isNotEmpty;

      if (_searchQuery.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts =
            _allProducts.where((doc) {
              String title =
                  (doc.data() as Map<String, dynamic>)['title']
                      ?.toString()
                      .toLowerCase() ??
                  '';
              String searchLower = _searchQuery.toLowerCase();

              bool matches = title.contains(searchLower);

              if (matches) {
                print('Match found: $title contains $searchLower');
              }

              return matches;
            }).toList();

        print('Search query: $_searchQuery');
        print('Found ${_filteredProducts.length} matches');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(252, 51, 78, 197),
        elevation: 10,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cari Comic & Light Novel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(252, 51, 78, 197),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: "Ketik judul comic atau light novel...",
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(252, 51, 78, 197),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color.fromARGB(252, 51, 78, 197),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                        : null,
                hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_isSearching) {
      return _buildInitialState();
    }

    if (_allProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color.fromARGB(252, 51, 78, 197)),
            SizedBox(height: 16),
            Text('Memuat data produk...'),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return _buildNoResults();
    }
    return _buildProductGrid(_filteredProducts);
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Mulai Pencarian',
            style: AppWidget.HeadLineTextFeildStyle().copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ketik judul comic atau light novel\nyang ingin Anda cari',
            style: AppWidget.LightTextFeildStyle().copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Tidak Ditemukan',
            style: AppWidget.HeadLineTextFeildStyle().copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Comic atau Light Novel dengan judul "$_searchQuery"\ntidak ditemukan',
            style: AppWidget.LightTextFeildStyle().copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<QueryDocumentSnapshot> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Text(
                'Hasil Pencarian',
                style: AppWidget.HeadLineTextFeildStyle(),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(252, 51, 78, 197),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${products.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.45,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(QueryDocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailScreen(
                  id: product.id,
                  image: data['image'],
                  title: data['title'],
                  author: data['author'],
                  price: data['price'],
                  category: data['genre'],
                  description: data['description'],
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Container(
                height: 250,
                width: double.infinity,
                child:
                    data['image'] != null
                        ? Image.memory(
                          base64Decode(data['image']),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'Judul tidak tersedia',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(252, 51, 78, 197),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data['genre'] ?? 'Genre',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(251, 255, 255, 255),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
