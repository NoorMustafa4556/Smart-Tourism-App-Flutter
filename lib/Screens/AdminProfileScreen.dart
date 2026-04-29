import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Services/DatabaseService.dart';

class AdminProfileScreen extends StatefulWidget {
  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _nameController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;
  String _existingProfilePic = "";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final stream = _db.getAdminProfile();
      final data = await stream.first;
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _existingProfilePic = data['profilePic'] ?? '';
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a name')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String profilePicUrl = _existingProfilePic;

      if (_imageFile != null) {
        // Upload new image
        final storageRef = FirebaseStorage.instance.ref().child('admin_images/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        if (kIsWeb) {
          await storageRef.putData(await _imageFile!.readAsBytes());
        } else {
          await storageRef.putFile(File(_imageFile!.path));
        }
        profilePicUrl = await storageRef.getDownloadURL();
      }

      await _db.updateAdminProfile(_nameController.text.trim(), profilePicUrl);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green));
      Navigator.pop(context); // Go back to Dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile: $e"), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Admin Profile", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber.shade900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _imageFile != null
                              ? (kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(File(_imageFile!.path))) as ImageProvider
                              : (_existingProfilePic.isNotEmpty ? CachedNetworkImageProvider(DatabaseService.getCORSProxyUrl(_existingProfilePic)) : null),
                          child: (_imageFile == null && _existingProfilePic.isEmpty)
                              ? Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.amber.shade900,
                            radius: 20,
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Admin Name",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55),
                      backgroundColor: Colors.amber.shade900,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("SAVE PROFILE", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }
}
