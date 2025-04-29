import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comicv_project/screens/favorite_screen.dart';

class DetailScreen extends StatefulWidget {
  final String image;
  final String title;
  final String author;
  final String price;
  final String category;
  final String description;

  const DetailScreen({
    super.key,
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
    // Cek apakah produk sudah ada di daftar favorit di Firestore
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
    };

    if (isFavorite) {
      // Hapus dari daftar favorit
      final snapshot =
          await FirebaseFirestore.instance
              .collection('favorites')
              .where('title', isEqualTo: widget.title)
              .where('author', isEqualTo: widget.author)
              .where('price', isEqualTo: widget.price)
              .where('category', isEqualTo: widget.category)
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
            "Dihapus dari Favorite",
            style: TextStyle(fontSize: 18.0, fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Tambahkan ke daftar favorit
      await FirebaseFirestore.instance
          .collection('favorites')
          .add(favoriteItem);

      setState(() {
        isFavorite = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ditambahkan ke Favorite",
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
            fontFamily: 'Poppins', // Menggunakan font Poppins
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk
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

              // Nama Produk
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),

              // Nama Penulis
              const SizedBox(height: 10),
              Text(
                "Author: ${widget.author}",
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),

              // Harga Produk
              Text(
                "Price: ${widget.price}",
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Kategori Produk
              Text(
                "Category: ${widget.category}",
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // Deskripsi Produk
              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.description,
                style: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
