import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicv_project/screens/favorite_screen.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String image;
  final String title;
  final String author;
  final String price;
  final String category;
  final String description;

  const DetailScreen({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.author,
    required this.price,
    required this.category,
    required this.description,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('favorites')
            .where('title', isEqualTo: widget.title)
            .where('author', isEqualTo: widget.author)
            .where('price', isEqualTo: widget.price)
            .where('category', isEqualTo: widget.category)
            .get();

    setState(() {
      isFavorite = snapshot.docs.isNotEmpty;
    });
  }

  Future<void> toggleFavorite(BuildContext context) async {
    final favoriteItem = {
      'image': widget.image,
      'title': widget.title,
      'author': widget.author,
      'price': widget.price,
      'category': widget.category,
      'description': widget.description,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'postId': widget.id,
    };

    if (isFavorite) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('favorites')
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid.toString(),
              )
              .where('postId', isEqualTo: widget.id)
              .get();

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        width: 90, // Lebar tetap untuk label
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
                          color: Colors.black, // Background hitam
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Rp.${widget.price}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.white, // Teks putih
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
                        width: 90, // Lebar tetap untuk label
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
                          color: Colors.black, // Background hitam
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.category,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.white, // Teks putih
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Center(
                child: const Text(
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
                    color: Colors.black, // Warna teks hitam
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
