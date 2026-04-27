import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../Models/PlaceModel.dart';
import '../Models/BookingModel.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';

class BookingFormScreen extends StatefulWidget {
  final PlaceModel place;
  final String category;

  BookingFormScreen({required this.place, required this.category});

  @override
  _BookingFormScreenState createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  File? _image;
  bool _isUploading = false;
  bool _isPickerActive = false;
  final String adminPaymentNumber = "0300-1234567 (EasyPaisa/JazzCash)";

  Future<void> _pickImage() async {
    if (_isPickerActive) return;
    setState(() => _isPickerActive = true);
    
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } finally {
      setState(() => _isPickerActive = false);
    }
  }

  void _submitBooking() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please upload payment screenshot")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final db = DatabaseService();

      // 1. Upload Screenshot
      String screenshotUrl = await db.uploadImage(_image!, 'payment_screenshots');

      // 2. Create Booking Object
      String bookingId = DateTime.now().millisecondsSinceEpoch.toString();
      BookingModel booking = BookingModel(
        bookingId: bookingId,
        userId: authProvider.userModel!.uid,
        userName: authProvider.userModel!.name,
        placeName: widget.place.name,
        category: widget.category,
        paymentScreenshot: screenshotUrl,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      // 3. Save to Firestore
      await db.createBooking(booking);

      setState(() => _isUploading = false);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Your booking request has been submitted. Wait for Admin approval."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close Form
                Navigator.pop(context); // Close Details
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Details")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin Payment Number:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                  SizedBox(height: 5),
                  Text(adminPaymentNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    "Note: Please send the total amount to this number and upload the screenshot below for verification.",
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text("Upload Payment Screenshot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          Text("Tap to select from gallery", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            Spacer(),
            _isUploading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("SUBMIT BOOKING", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}
