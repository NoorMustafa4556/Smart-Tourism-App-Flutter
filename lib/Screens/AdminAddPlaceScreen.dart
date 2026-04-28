import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/DatabaseService.dart';
import '../Models/PlaceModel.dart';

class AdminAddPlaceScreen extends StatefulWidget {
  final PlaceModel? placeToEdit;

  AdminAddPlaceScreen({this.placeToEdit});

  @override
  _AdminAddPlaceScreenState createState() => _AdminAddPlaceScreenState();
}

class _AdminAddPlaceScreenState extends State<AdminAddPlaceScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  
  XFile? _image;
  String? _existingImageUrl;
  bool _isLoading = false;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.placeToEdit != null) {
      _nameController.text = widget.placeToEdit!.name;
      _descriptionController.text = widget.placeToEdit!.description;
      _locationController.text = widget.placeToEdit!.location;
      _priceController.text = widget.placeToEdit!.price.toString();
      _existingImageUrl = widget.placeToEdit!.image;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _image = pickedFile);
    }
  }

  void _savePlace() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _locationController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    if (_image == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select an image.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';
      if (_image != null) {
        imageUrl = await _db.uploadImage(_image!, 'place_images');
      }
      
      String placeId = widget.placeToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      PlaceModel newPlace = PlaceModel(
        id: placeId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        image: imageUrl,
        location: _locationController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );

      if (widget.placeToEdit != null) {
        await _db.updatePlace(newPlace);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Place updated successfully!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      } else {
        await _db.createPlace(newPlace);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Place added successfully!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      }
      
      setState(() => _isLoading = false);
      Navigator.pop(context); // Go back to dashboard
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.placeToEdit != null ? "EDIT PLACE" : "ADD NEW PLACE", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.amber.shade900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _image == null && _existingImageUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                          Text("Tap to upload Place Image", style: GoogleFonts.poppins(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _image != null
                          ? (kIsWeb ? Image.network(_image!.path, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.error)) : Image.file(File(_image!.path), fit: BoxFit.cover))
                          : Image.network(
                              DatabaseService.getCORSProxyUrl(_existingImageUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                    SizedBox(height: 5),
                                    Text("Web Preview Blocked (CORS)\nImage is saved.", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                );
                              },
                            ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(_nameController, "Place Name", Icons.landscape),
            SizedBox(height: 15),
            _buildTextField(_locationController, "Location", Icons.location_on),
            SizedBox(height: 15),
            _buildTextField(_priceController, "Base Price (Rs)", Icons.attach_money, isNumber: true),
            SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _savePlace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade900,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(widget.placeToEdit != null ? "UPDATE PLACE" : "SAVE PLACE", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.amber.shade900),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
