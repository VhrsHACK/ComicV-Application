import 'dart:convert';
import 'package:comicv_project/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicv_project/widgets/widget_support.dart';
import 'package:comicv_project/screens/navbottom_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavBottomScreen();
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    final List<String> bannerImages = [
      'assets/images/banner1.png',
      'assets/images/banner2.png',
      'assets/images/banner3.png',
      'assets/images/banner4.png',
      'assets/images/banner5.png',
      'assets/images/banner6.png',
      'assets/images/banner7.png',
      'assets/images/banner8.png',
    ];

    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(252, 51, 78, 197),
                  Color.fromARGB(252, 51, 78, 197),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 3.5,
            ),
            height: MediaQuery.of(context).size.height / 0.5,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hello, Reader",
                      style: AppWidget.boldTextFeildStyle().copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Image.asset(
                      'assets/images/app_logo.png',
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Cari Comic atau Light Novels",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(252, 51, 78, 197),
                    ),
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(252, 51, 78, 197),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(251, 255, 255, 255),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Text(
                    "Welcome to ComicV",
                    style: AppWidget.HeadLineTextFeildStyle().copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Telusuri Comic dan Light Novel Terbaik Anda",
                    style: AppWidget.LightTextFeildStyle().copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 60.0),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 180.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items:
                      bannerImages.map((imagePath) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              ),
                            );
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Popular Comics",
                  style: AppWidget.HeadLineTextFeildStyle(),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton("All"),
                    _buildCategoryButton("Light Novel"),
                    _buildCategoryButton("Novel"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton("Manhwa"),
                    _buildCategoryButton("Manhua"),
                    _buildCategoryButton("Manga"),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _getFilteredStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No products available."),
                      );
                    }
                    final products = snapshot.data!.docs;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.48,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailScreen(
                                      id: product.id,
                                      image: product['image'],
                                      title: product['title'],
                                      author: product['author'],
                                      price: product['price'],
                                      category: product['genre'],
                                      description: product['description'],
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child:
                                      product['image'] != null
                                          ? Image.memory(
                                            base64Decode(product['image']),
                                            height: 250,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                          : const Icon(Icons.image, size: 250),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        product['genre'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category == "All" ? '' : category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              _selectedCategory == category ||
                      (category == "All" && _selectedCategory.isEmpty)
                  ? const Color.fromARGB(252, 51, 78, 197)
                  : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color:
                _selectedCategory == category ||
                        (category == "All" && _selectedCategory.isEmpty)
                    ? Colors.white
                    : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    if (_searchQuery.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: _searchQuery)
          .where('title', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
          .snapshots();
    } else if (_selectedCategory.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('genre', isEqualTo: _selectedCategory)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }
}
