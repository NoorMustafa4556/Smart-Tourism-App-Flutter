import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Models/PlaceModel.dart';
import '../Models/HotelModel.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';
import 'BookingFormScreen.dart';

class BookingDetailsFormScreen extends StatefulWidget {
  final PlaceModel place;
  final HotelModel? hotel;
  final int? totalDays;
  final double? totalPrice;

  BookingDetailsFormScreen({required this.place, this.hotel, this.totalDays, this.totalPrice});

  @override
  _BookingDetailsFormScreenState createState() => _BookingDetailsFormScreenState();
}

class _BookingDetailsFormScreenState extends State<BookingDetailsFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  int _persons = 1;
  int _days = 1;
  DateTime? _selectedDate;
  String _selectedCategory = 'Family';
  HotelModel? _selectedHotel;
  final List<String> _categories = ['Family', 'Single', 'Friends', 'Couple'];

  @override
  void initState() {
    super.initState();
    if (widget.totalDays != null) _days = widget.totalDays!;
    _selectedHotel = widget.hotel;
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
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all required fields and select a date")));
      return;
    }

    double placeCost = widget.place.price * _persons;
    double hotelCost = (_selectedHotel?.pricePerNight ?? 0) * _days;
    double totalPrice = placeCost + hotelCost;

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
          hotelName: _selectedHotel?.name,
          startDate: _selectedDate != null ? DateFormat('dd MMM yyyy').format(_selectedDate!) : null,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    double placeCost = widget.place.price * _persons;
    double hotelCost = (_selectedHotel?.pricePerNight ?? 0) * _days;
    double currentTotal = placeCost + hotelCost;

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
            _buildTextField(_phoneController, "Phone Number", Icons.phone, isPhone: true, isLast: true),
            SizedBox(height: 25),
            
            Text("Accommodation", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildHotelSelector(),
            SizedBox(height: 20),
            
            _buildDropdown(),
            SizedBox(height: 15),
            _buildDatePicker(),
            SizedBox(height: 20),
            
            _buildCounterRow("Number of Persons", _persons, (val) => setState(() => _persons = val)),
            SizedBox(height: 15),
            _buildCounterRow("Number of Days", _days, (val) => setState(() => _days = val)),
            
            SizedBox(height: 30),
            _buildPriceBreakdown(),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Payable:", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Rs. ${currentTotal.toInt()}", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber.shade400)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false, bool isPhone = false, bool isLast = false}) {
    return TextField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
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

  Widget _buildHotelSelector() {
    return StreamBuilder<List<HotelModel>>(
      stream: DatabaseService().getSpotHotels(widget.place.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        final hotels = snapshot.data!;
        if (hotels.isEmpty) return Text("No hotels available for this location.", style: TextStyle(color: Colors.grey, fontSize: 12));

        return Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              final isSelected = _selectedHotel?.id == hotel.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedHotel = hotel),
                child: Container(
                  width: 140,
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade900 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(hotel.name, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("Rs. ${hotel.pricePerNight.toInt()}/night", style: TextStyle(color: isSelected ? Colors.white70 : Colors.blue.shade900, fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
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

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF004E92)),
            SizedBox(width: 15),
            Text(
              _selectedDate == null ? "Select Start Date" : "Start Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}",
              style: TextStyle(color: _selectedDate == null ? Colors.grey.shade600 : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    double placeTotal = widget.place.price * _persons;
    double hotelTotal = (_selectedHotel?.pricePerNight ?? 0) * _days;

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Price Breakdown", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
          Divider(),
          _priceRow("Place: ${widget.place.name}", "Rs. ${widget.place.price.toInt()} x $_persons persons", placeTotal),
          if (_selectedHotel != null)
            _priceRow("Hotel: ${_selectedHotel!.name}", "Rs. ${_selectedHotel!.pricePerNight.toInt()} x $_days nights", hotelTotal),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String subtitle, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Text("Rs. ${amount.toInt()}", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
