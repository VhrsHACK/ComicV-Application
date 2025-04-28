/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorite_screen.dart';

class DetailScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final String genre;
  final String description;

  const DetailScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
  });

  Future<void> addToFavorites(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('favorites').add({
        'imageUrl': imageUrl,
        'title': title,
        'author': author,
        'genre': genre,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to Favorites!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add to favorites: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Gradient
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
            // White Container with Rounded Corners
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 3,
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
            // Content
            Container(
              margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comic/Light Novel Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        width: MediaQuery.of(context).size.width * 0.8,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title and Favorite Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => addToFavorites(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Author
                  Center(
                    child: Text(
                      "By $author",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Genre
                  const Text(
                    "Genre",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

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
