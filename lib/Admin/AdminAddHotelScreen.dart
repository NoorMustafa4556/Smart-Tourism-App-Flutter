import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Services/DatabaseService.dart';
import '../Models/HotelModel.dart';
import '../Models/PlaceModel.dart';

class AdminAddHotelScreen extends StatefulWidget {
  final HotelModel? hotelToEdit;
  AdminAddHotelScreen({this.hotelToEdit});

  @override
  _AdminAddHotelScreenState createState() => _AdminAddHotelScreenState();
}

class _AdminAddHotelScreenState extends State<AdminAddHotelScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  
  XFile? _image;
  String? _existingImageUrl;
  String? _selectedSpotId;
  bool _isLoading = false;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.hotelToEdit != null) {
      _nameController.text = widget.hotelToEdit!.name;
      _priceController.text = widget.hotelToEdit!.pricePerNight.toString();
      _selectedSpotId = widget.hotelToEdit!.spotId;
      _existingImageUrl = widget.hotelToEdit!.image;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _image = pickedFile);
    }
  }

  void _saveHotel() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedSpotId == null || (_image == null && _existingImageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and select image.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';
      if (_image != null) {
        imageUrl = await _db.uploadImage(_image!, 'hotel_images');
      }
      
      HotelModel newHotel = HotelModel(
        id: widget.hotelToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        image: imageUrl,
        pricePerNight: double.parse(_priceController.text.trim()),
        spotId: _selectedSpotId!,
      );

      if (widget.hotelToEdit != null) {
        await _db.updateHotel(newHotel);
      } else {
        await _db.createHotel(newHotel);
      }
      
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.hotelToEdit != null ? "Hotel updated!" : "Hotel added!")));
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.hotelToEdit != null ? "EDIT HOTEL" : "ADD HOTEL", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                          Text("Tap to upload Hotel Image", style: GoogleFonts.poppins(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _image != null 
                          ? (kIsWeb ? Image.network(_image!.path, fit: BoxFit.cover) : Image.file(File(_image!.path), fit: BoxFit.cover))
                          : CachedNetworkImage(imageUrl: DatabaseService.getCORSProxyUrl(_existingImageUrl!), fit: BoxFit.cover),
                      ),
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder<List<PlaceModel>>(
              stream: _db.getPlaces(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Tourist Spot",
                    prefixIcon: Icon(Icons.location_on, color: Colors.blue.shade900),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  items: snapshot.data!.map((spot) => DropdownMenuItem(value: spot.id, child: Text(spot.name))).toList(),
                  onChanged: (val) => setState(() => _selectedSpotId = val),
                  value: _selectedSpotId,
                );
              },
            ),
            SizedBox(height: 15),
            _buildTextField(_nameController, "Hotel Name", Icons.hotel),
            SizedBox(height: 15),
            _buildTextField(_priceController, "Price Per Night (Rs)", Icons.attach_money, isNumber: true, isLast: true),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveHotel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(widget.hotelToEdit != null ? "UPDATE HOTEL" : "SAVE HOTEL", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isLast = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
