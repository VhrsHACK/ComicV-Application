import 'dart:convert';
import 'package:comicv_project/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicv_project/widgets/widget_support.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = '';
  String _selectedCondition = '';

  final List<String> categories = [
    'All',
    'Light Novel',
    'Novel',
    'Manhwa',
    'Manhua',
    'Manga',
  ];

  final List<String> conditions = ['All Conditions', 'Baru', 'Bekas'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(252, 51, 78, 197),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(252, 51, 78, 197),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Category & Condition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                _selectedCategory.isEmpty
                                    ? 'All'
                                    : _selectedCategory,
                            isExpanded: true,
                            hint: const Text('Select Category'),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color.fromARGB(252, 51, 78, 197),
                            ),
                            items:
                                categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory =
                                    newValue == 'All' ? '' : newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                _selectedCondition.isEmpty
                                    ? 'All Conditions'
                                    : _selectedCondition,
                            isExpanded: true,
                            hint: const Text('Select Condition'),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color.fromARGB(252, 51, 78, 197),
                            ),
                            items:
                                conditions.map((String condition) {
                                  return DropdownMenuItem<String>(
                                    value: condition,
                                    child: Text(
                                      condition,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCondition =
                                    newValue == 'All Conditions'
                                        ? ''
                                        : newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Categories',
                  style: AppWidget.HeadLineTextFeildStyle(),
                ),
                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildCategoryChip("All"),
                    ...categories.skip(1).map((category) {
                      return _buildCategoryChip(category);
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Results',
                        style: AppWidget.HeadLineTextFeildStyle(),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: _getFilteredStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data!.docs.length} items found',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _getFilteredStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No items found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Try adjusting your filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final products = snapshot.data!.docs;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected =
        _selectedCategory == category ||
        (category == "All" && _selectedCategory.isEmpty);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category == "All" ? '' : category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color.fromARGB(252, 51, 78, 197)
                  : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color.fromARGB(252, 51, 78, 197),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color:
                isSelected
                    ? Colors.white
                    : const Color.fromARGB(252, 51, 78, 197),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(DocumentSnapshot product) {
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                      (product.data() as Map<String, dynamic>).containsKey(
                        'condition',
                      ) &&
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
                          color: _getConditionColor(product['condition']),
                          borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product['genre'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
