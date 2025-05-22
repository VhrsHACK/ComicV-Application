import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicv_project/screens/favorite_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String image;
  final String title;
  final String author;
  final String price;
  final String category;
  final String description;
  final String condition;

  const DetailScreen({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.author,
    required this.price,
    required this.category,
    required this.description,
    this.condition = 'N/A',
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  double? postLatitude;
  double? postLongitude;
  String bookCondition = 'N/A';

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _getPostLocation();
    _getBookCondition();
  }

  Future<void> _getBookCondition() async {
    try {
      if (widget.condition != 'N/A') {
        setState(() {
          bookCondition = widget.condition;
        });
        return;
      }

      final postDoc =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.id)
              .get();

      if (postDoc.exists) {
        final data = postDoc.data();
        if (data != null && data.containsKey('condition')) {
          setState(() {
            bookCondition = data['condition'];
          });
        }
      }
    } catch (e) {
      print('Error fetching book condition: $e');
    }
  }

  Future<void> _getPostLocation() async {
    try {
      final postDoc =
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.id)
              .get();

      if (postDoc.exists) {
        final data = postDoc.data();
        if (data != null &&
            data.containsKey('latitude') &&
            data.containsKey('longitude')) {
          setState(() {
            postLatitude = data['latitude'];
            postLongitude = data['longitude'];
          });
        }
      }
    } catch (e) {
      print('Error fetching location data: $e');
    }
  }

  Future<void> _openMaps() async {
    if (postLatitude != null && postLongitude != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=$postLatitude,$postLongitude';

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Tidak dapat membuka maps",
              style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Data lokasi tidak tersedia",
            style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // PERBAIKAN: Tambah filter berdasarkan userId
  Future<void> _checkIfFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        isFavorite = false;
      });
      return;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('favorites')
              .where(
                'userId',
                isEqualTo: currentUser.uid,
              ) // Filter berdasarkan userId
              .where(
                'postId',
                isEqualTo: widget.id,
              ) // Gunakan postId untuk identifikasi yang lebih akurat
              .get();

      setState(() {
        isFavorite = snapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
      setState(() {
        isFavorite = false;
      });
    }
  }

  // PERBAIKAN: Optimasi method toggleFavorite
  Future<void> toggleFavorite(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Silakan login terlebih dahulu",
            style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (isFavorite) {
        // Hapus dari favorite
        final snapshot =
            await FirebaseFirestore.instance
                .collection('favorites')
                .where('userId', isEqualTo: currentUser.uid)
                .where('postId', isEqualTo: widget.id)
                .get();

        // Hapus semua dokumen yang cocok
        for (var doc in snapshot.docs) {
          await FirebaseFirestore.instance
              .collection('favorites')
              .doc(doc.id)
              .delete();
        }

        setState(() {
          isFavorite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Comic Dihapus Dari Favorite",
              style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Tambah ke favorite
        final favoriteItem = {
          'image': widget.image,
          'title': widget.title,
          'author': widget.author,
          'price': widget.price,
          'category': widget.category,
          'description': widget.description,
          'condition': bookCondition,
          'userId': currentUser.uid, // Pastikan userId disimpan
          'postId': widget.id, // Gunakan postId untuk identifikasi
          'createdAt': FieldValue.serverTimestamp(), // Tambah timestamp
        };

        await FirebaseFirestore.instance
            .collection('favorites')
            .add(favoriteItem);

        setState(() {
          isFavorite = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Comic Ditambahkan Ke Favorite",
              style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
            ),
            backgroundColor: Color.fromARGB(252, 51, 78, 197),
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Terjadi kesalahan saat memproses favorite",
            style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Product",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color.fromARGB(252, 51, 78, 197),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => toggleFavorite(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child:
                          widget.image.isNotEmpty
                              ? Image.memory(
                                base64Decode(widget.image),
                                height: 500,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                              : const Icon(
                                Icons.image,
                                size: 300,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: const Color.fromARGB(252, 51, 78, 197),
                      onPressed: _openMaps,
                      child: const Icon(Icons.location_on, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            "Author",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.author,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            "Price",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Rp.${widget.price}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            "Category",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.category,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            "Kondisi",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                bookCondition.toLowerCase() == 'baru'
                                    ? Colors.green
                                    : (bookCondition.toLowerCase() == 'bekas'
                                        ? Colors.orange
                                        : Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bookCondition,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Sinopsis",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
