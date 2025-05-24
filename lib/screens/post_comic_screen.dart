import 'dart:io';
import 'dart:convert';
import 'package:comicv_project/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostComicScreen extends StatefulWidget {
  const PostComicScreen({super.key});

  @override
  State<PostComicScreen> createState() => _PostComicScreenState();
}

class _PostComicScreenState extends State<PostComicScreen> {
  File? _image;
  String? _base64Image;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double? _latitude;
  double? _longitude;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _compressAndEncodeImage();
    }
  }

  Future<void> _compressAndEncodeImage() async {
    if (_image == null) return;
    final compressedImage = await FlutterImageCompress.compressWithFile(
      _image!.path,
      quality: 50,
    );
    if (compressedImage == null) return;
    setState(() {
      _base64Image = base64Encode(compressedImage);
    });
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 20));
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      debugPrint('Failed to retrieve location: $e');
      setState(() {
        _latitude = null;
        _longitude = null;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_base64Image == null ||
        _titleController.text.isEmpty ||
        _authorController.text.isEmpty ||
        _genreController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _conditionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mohon lengkapi semua data termasuk gambar',
                  style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    final now = DateTime.now().toIso8601String();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('User tidak ditemukan'),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await _getLocation();

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final fullName = userDoc.data()?['fullName'] ?? 'Anonymous';

      await FirebaseFirestore.instance.collection('posts').add({
        'image': _base64Image,
        'title': _titleController.text,
        'author': _authorController.text,
        'genre': _genreController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'condition': _conditionController.text,
        'createdAt': now,
        'latitude': _latitude,
        'longitude': _longitude,
        'fullName': fullName,
        'userId': uid,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Comic berhasil diupload!',
                style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Upload failed: $e');
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Gagal mengupload comic'),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Pilih Sumber Gambar",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              "Pilih dari mana Anda ingin mengambil foto comic",
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Kamera"),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(252, 51, 78, 197),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text("Galeri"),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(252, 51, 78, 197),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty ? controller.text : null,
        items: items,
        onChanged: (value) {
          setState(() {
            controller.text = value ?? '';
          });
        },
        style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(icon, color: const Color.fromARGB(252, 51, 78, 197)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Container(
            height: 150,
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Post Comic",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Foto Comic",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _image == null ? _showImageSourceDialog : null,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          _image != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Image.file(
                                      _image!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: _showImageSourceDialog,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        252,
                                        51,
                                        78,
                                        197,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Color.fromARGB(252, 51, 78, 197),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Tambahkan Foto Comic",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      color: Color.fromARGB(252, 51, 78, 197),
                                    ),
                                  ),
                                  const Text(
                                    "Tap untuk memilih foto",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF636E72),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Detail Comic",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _titleController,
                    hintText: 'Judul Comic',
                    icon: Icons.book,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _authorController,
                    hintText: 'Author Comic',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _priceController,
                    hintText: 'Harga Comic (Rp)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    controller: _genreController,
                    hintText: 'Pilih Kategori',
                    icon: Icons.category,
                    items: const [
                      DropdownMenuItem(
                        value: 'Light Novel',
                        child: Text('Light Novel'),
                      ),
                      DropdownMenuItem(value: 'Novel', child: Text('Novel')),
                      DropdownMenuItem(value: 'Manhwa', child: Text('Manhwa')),
                      DropdownMenuItem(value: 'Manhua', child: Text('Manhua')),
                      DropdownMenuItem(value: 'Manga', child: Text('Manga')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    controller: _conditionController,
                    hintText: 'Pilih Kondisi Buku',
                    icon: Icons.star,
                    items: const [
                      DropdownMenuItem(value: 'Baru', child: Text('Baru')),
                      DropdownMenuItem(value: 'Bekas', child: Text('Bekas')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _descriptionController,
                    hintText: 'Deskripsi Comic',
                    icon: Icons.description,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child:
                        _isUploading
                            ? Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(252, 51, 78, 197),
                                    Color.fromARGB(255, 74, 144, 226),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Uploading...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ElevatedButton(
                              onPressed: _submitPost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(252, 51, 78, 197),
                                      Color.fromARGB(255, 74, 144, 226),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.publish, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Post Comic",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
