import 'dart:convert';
import 'dart:io';
import 'package:comicv_project/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  File? _profileImage;
  String? _profileImageBase64;
  bool _isImageChanged = false;
  String? _password;

  @override
  void initState() {
    super.initState();
    _fetchUserPassword();
  }

  Future<void> _fetchUserPassword() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .get();

      if (doc.exists) {
        setState(() {
          _password = doc.data()?['password'] ?? "No Password";
        });
      } else {
        setState(() {
          _password = "No Password";
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil password pengguna: $e");
      setState(() {
        _password = "No Password";
      });
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _profileImageBase64 = base64Encode(_profileImage!.readAsBytesSync());
        _isImageChanged = true;
      });
    }
  }

  Future<void> _saveProfileImageToFirestore() async {
    if (_profileImageBase64 == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({'profileImage': _profileImageBase64});

      setState(() {
        _isImageChanged = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto profil berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan foto profil: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _getProfileImageFromFirestore() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .get();

      return doc.data()?['profileImage'];
    } catch (e) {
      debugPrint("Gagal mengambil foto profil: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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

            Container(
              margin: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Profile Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Center(
                    child: FutureBuilder<String?>(
                      future: _getProfileImageFromFirestore(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final profileImageBase64 = snapshot.data;
                        return GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (profileImageBase64 != null
                                        ? MemoryImage(
                                          base64Decode(profileImageBase64),
                                        )
                                        : null),
                            child:
                                _profileImage == null &&
                                        profileImageBase64 == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.black,
                                    )
                                    : null,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 130),
                  Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            user?.email ?? "No Email",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "********",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_isImageChanged)
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveProfileImageToFirestore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            252,
                            51,
                            78,
                            197,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          "Save Profile Picture",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontFamily: 'Poppins1',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => signOut(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(252, 51, 78, 197),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: 'Poppins1',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
