/*import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Comics")),
      body: const Center(
        child: Text(
          "Favorite Screen",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
} */

/*
Code terbaru yang sudah dikonfigurasi dengan firebase dan juga dengan detail_screen.dart


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: const Color.fromARGB(252, 51, 78, 197),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('favorites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final favoriteDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoriteDocs.length,
            itemBuilder: (context, index) {
              final favorite = favoriteDocs[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    favorite['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(favorite['title']),
                subtitle: Text(favorite['author']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        imageUrl: favorite['imageUrl'],
                        title: favorite['title'],
                        author: favorite['author'],
                        genre: favorite['genre'],
                        description: favorite['description'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  static final List<Map<String, String>> favorites = [];

  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Favorites",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(252, 51, 78, 197),
        automaticallyImplyLeading: false,
      ),
      body:
          favorites.isEmpty
              ? const Center(
                child: Text(
                  "No favorites yet!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final favorite = favorites[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigasi ke DetailScreen dengan data produk favorit
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DetailScreen(
                                image: favorite['image']!,
                                title: favorite['title']!,
                                author: favorite['author']!,
                                price: favorite['price']!,
                                category: favorite['category']!,
                              ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            favorite['image']!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          favorite['title']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Author: ${favorite['author']!}\nPrice: ${favorite['price']!}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Text(
                          favorite['category']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
