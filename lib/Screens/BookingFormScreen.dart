import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/PlaceModel.dart';
import '../Models/BookingModel.dart';
import '../Models/PaymentMethodModel.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';
import 'HomeScreen.dart';

class BookingFormScreen extends StatefulWidget {
  final PlaceModel place;
  final String name;
  final String email;
  final String phone;
  final int persons;
  final int days;
  final String category;
  final double totalPrice;
  final String? hotelName;
  final String? startDate;

  BookingFormScreen({
    required this.place,
    required this.name,
    required this.email,
    required this.phone,
    required this.persons,
    required this.days,
    required this.category,
    required this.totalPrice,
    this.hotelName,
    this.startDate,
  });

  @override
  _BookingFormScreenState createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  XFile? _image;
  bool _isUploading = false;
  PaymentMethodModel? _selectedPaymentMethod;
  final DatabaseService _db = DatabaseService();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _image = pickedFile);
    }
  }

  void _submitBooking() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a payment method.")));
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please upload payment screenshot.")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      String screenshotUrl = await _db.uploadImage(_image!, 'payment_screenshots');
      String bookingId = DateTime.now().millisecondsSinceEpoch.toString();

      BookingModel booking = BookingModel(
        bookingId: bookingId,
        userId: authProvider.userModel!.uid,
        userName: widget.name,
        email: widget.email,
        phone: widget.phone,
        placeName: widget.place.name,
        category: widget.category,
        persons: widget.persons,
        days: widget.days,
        totalPrice: widget.totalPrice,
        paymentMethod: _selectedPaymentMethod!.methodName,
        paymentScreenshot: screenshotUrl,
        status: 'pending',
        adminRemarks: '',
        timestamp: DateTime.now(),
        hotelName: widget.hotelName,
        totalDays: widget.days,
        startDate: widget.startDate,
      );

      await _db.createBooking(booking);

      setState(() => _isUploading = false);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("Booking Request Sent!"),
          content: Text("Your payment proof and details have been sent to the Admin. Please wait for approval."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
              },
              child: Text("Go to Home"),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Payment", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<PaymentMethodModel>>(
        stream: _db.getPaymentMethods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          final methods = snapshot.data ?? [];
          
          if (methods.isEmpty) {
            return Center(child: Text("No payment methods available. Please contact admin."));
          }

          // Auto-select first method if null
          if (_selectedPaymentMethod == null || !methods.any((m) => m.id == _selectedPaymentMethod!.id)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _selectedPaymentMethod = methods.first);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Amount to Pay: Rs. ${widget.totalPrice.toInt()}", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                SizedBox(height: 20),
                
                Text("Select Payment Method", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentMethodModel>(
                      isExpanded: true,
                      value: _selectedPaymentMethod,
                      items: methods.map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.methodName, style: GoogleFonts.poppins()),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                if (_selectedPaymentMethod != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Send Payment To:", style: GoogleFonts.poppins(color: Colors.blue.shade900)),
                        SizedBox(height: 5),
                        Text("${_selectedPaymentMethod!.accountTitle}\n${_selectedPaymentMethod!.accountNumber}", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                      ],
                    ),
                  ),
                
                SizedBox(height: 30),
                Text("Upload Payment Screenshot", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
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
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                              Text("Tap to upload receipt", style: GoogleFonts.poppins(color: Colors.grey)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15), 
                            child: kIsWeb 
                              ? Image.network(_image!.path, fit: BoxFit.cover) 
                              : Image.file(File(_image!.path), fit: BoxFit.cover),
                          ),
                  ),
                ),
                
                SizedBox(height: 40),
                _isUploading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text("SUBMIT PROOF & BOOK", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
