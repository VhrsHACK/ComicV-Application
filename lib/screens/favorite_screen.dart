import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            );
          }

          final favoriteDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoriteDocs.length,
            itemBuilder: (context, index) {
              final favorite = favoriteDocs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DetailScreen(
                            image: favorite['image'],
                            title: favorite['title'],
                            author: favorite['author'],
                            price: favorite['price'],
                            category: favorite['category'],
                            description: favorite['description'],
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
                      child:
                          favorite['image'] != null
                              ? Image.memory(
                                base64Decode(favorite['image']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              : const Icon(Icons.image, size: 50),
                    ),
                    title: Text(
                      favorite['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Author: ${favorite['author'] ?? 'Unknown'}\nPrice: ${favorite['price'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      favorite['category'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
