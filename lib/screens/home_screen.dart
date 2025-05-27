import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:comicv_project/screens/detail_screen.dart';
import 'package:comicv_project/screens/category_screen.dart';
import 'package:comicv_project/screens/searchbar_screen.dart';
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
  String _selectedCategory = '';
  String _selectedCondition = '';

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
                  Color.fromARGB(255, 74, 144, 226),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 3.5,
            ),
            height: MediaQuery.of(context).size.height / 0.1,
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchBarScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Color.fromARGB(252, 51, 78, 197),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Cari Comic atau Light Novels",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
                    "Telusuri Comic dan Light Novel Terbaik",
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
                    viewportFraction: 0.9,
                  ),
                  items:
                      bannerImages.map((imagePath) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Comic Terbaru",
                      style: AppWidget.HeadLineTextFeildStyle(),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CategoryScreen(
                                  initialCategory: _selectedCategory,
                                  initialCondition: _selectedCondition,
                                ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedCategory = result['category'] ?? '';
                            _selectedCondition = result['condition'] ?? '';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(252, 51, 78, 197),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Filter",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_selectedCategory.isNotEmpty ||
                    _selectedCondition.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 16,
                              color: const Color.fromARGB(252, 51, 78, 197),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Filter Sedang Aktif:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(252, 51, 78, 197),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_selectedCategory.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    252,
                                    51,
                                    78,
                                    197,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      252,
                                      51,
                                      78,
                                      197,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedCategory,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(252, 51, 78, 197),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = '';
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Color.fromARGB(252, 51, 78, 197),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_selectedCondition.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getConditionColor(
                                    _selectedCondition,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: _getConditionColor(
                                      _selectedCondition,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getConditionColor(
                                          _selectedCondition,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _selectedCondition,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getConditionColor(
                                          _selectedCondition,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCondition = '';
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: _getConditionColor(
                                          _selectedCondition,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                StreamBuilder<QuerySnapshot>(
                  stream: _getFilteredStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '${snapshot.data!.docs.length} Comic/Light Novel ditemukan',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _getFilteredStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Comic/Light Novel tidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Silahkan benarkan filter anda',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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
                                  color: Colors.grey.withOpacity(0.3),
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
                                  child: Stack(
                                    children: [
                                      product['image'] != null
                                          ? Image.memory(
                                            base64Decode(product['image']),
                                            height: 250,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            height: 250,
                                            width: double.infinity,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.image,
                                              size: 80,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      if (product.data() != null &&
                                          (product.data()
                                                  as Map<String, dynamic>)
                                              .containsKey('condition') &&
                                          product['condition'] != null)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getConditionColor(
                                                product['condition'],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              product['condition'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
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

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'baru':
        return Colors.green;
      case 'bekas':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    CollectionReference postsRef = FirebaseFirestore.instance.collection(
      'posts',
    );

    if (_selectedCategory.isNotEmpty) {
      if (_selectedCondition.isNotEmpty) {
        return postsRef
            .where('genre', isEqualTo: _selectedCategory)
            .where('condition', isEqualTo: _selectedCondition)
            .snapshots();
      } else {
        return postsRef
            .where('genre', isEqualTo: _selectedCategory)
            .snapshots();
      }
    } else if (_selectedCondition.isNotEmpty) {
      return postsRef
          .where('condition', isEqualTo: _selectedCondition)
          .snapshots();
    } else {
      return postsRef.orderBy('createdAt', descending: true).snapshots();
    }
  }
}
