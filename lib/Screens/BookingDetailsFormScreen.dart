import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Models/PlaceModel.dart';
import '../Providers/AuthProvider.dart';
import 'BookingFormScreen.dart';

class BookingDetailsFormScreen extends StatefulWidget {
  final PlaceModel place;

  BookingDetailsFormScreen({required this.place});

  @override
  _BookingDetailsFormScreenState createState() => _BookingDetailsFormScreenState();
}

class _BookingDetailsFormScreenState extends State<BookingDetailsFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  int _persons = 1;
  int _days = 1;
  String _selectedCategory = 'Family';
  final List<String> _categories = ['Family', 'Single', 'Friends', 'Couple'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      if (user != null) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone;
        });
      }
    });
  }

  void _proceedToPayment() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    double totalPrice = widget.place.price * _persons * _days;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingFormScreen(
          place: widget.place,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          persons: _persons,
          days: _days,
          category: _selectedCategory,
          totalPrice: totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double currentTotal = widget.place.price * _persons * _days;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Booking Details", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF004E92),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fill details for ${widget.place.name}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            
            _buildTextField(_nameController, "Full Name", Icons.person),
            SizedBox(height: 15),
            _buildTextField(_emailController, "Email Address", Icons.email, isEmail: true),
            SizedBox(height: 15),
            _buildTextField(_phoneController, "Phone Number", Icons.phone, isPhone: true),
            SizedBox(height: 20),
            
            _buildDropdown(),
            SizedBox(height: 20),
            
            _buildCounterRow("Number of Persons", _persons, (val) => setState(() => _persons = val)),
            SizedBox(height: 15),
            _buildCounterRow("Number of Days", _days, (val) => setState(() => _days = val)),
            
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Price:", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                  Text("Rs. ${currentTotal.toInt()}", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF004E92),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("CONFIRM & PAY", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false, bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF004E92)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: "Category",
        prefixIcon: Icon(Icons.group, color: Color(0xFF004E92)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val!),
    );
  }

  Widget _buildCounterRow(String title, int currentValue, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: currentValue > 1 ? () => onChanged(currentValue - 1) : null,
            ),
            Text(currentValue.toString(), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () => onChanged(currentValue + 1),
            ),
          ],
        )
      ],
    );
  }
}
