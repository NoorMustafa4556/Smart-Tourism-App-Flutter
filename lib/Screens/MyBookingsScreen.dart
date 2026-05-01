import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Models/BookingModel.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';

class MyBookingsScreen extends StatefulWidget {
  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("My Bookings", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFF004E92),
          iconTheme: IconThemeData(color: Colors.white),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: StreamBuilder<List<BookingModel>>(
          stream: _db.getUserBookings(authProvider.userModel!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
            final allBookings = snapshot.data ?? [];
            
            return TabBarView(
              children: [
                _buildBookingList(allBookings.where((b) => b.status.toLowerCase() == 'pending').toList()),
                _buildBookingList(allBookings.where((b) => b.status.toLowerCase() == 'approved' || b.status.toLowerCase() == 'processed').toList()),
                _buildBookingList(allBookings.where((b) => b.status.toLowerCase() == 'rejected').toList()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
            SizedBox(height: 15),
            Text("No bookings in this category.", style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(15),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: EdgeInsets.only(bottom: 15),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(booking.placeName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text("Total: Rs. ${booking.totalPrice.toInt()}", style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _getStatusColor(booking.status), borderRadius: BorderRadius.circular(20)),
                child: Text(booking.status.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      if (booking.hotelName != null) 
                        _detailRow(Icons.hotel, "Hotel", booking.hotelName!),
                      if (booking.startDate != null)
                        _detailRow(Icons.calendar_today, "Start Date", booking.startDate!),
                      _detailRow(Icons.group, "Persons", "${booking.persons}"),
                      _detailRow(Icons.timer, "Duration", "${booking.days} Days"),
                      _detailRow(Icons.category, "Category", booking.category),
                      _detailRow(Icons.credit_card, "Payment", booking.paymentMethod),
                      _detailRow(Icons.access_time, "Booked On", DateFormat('dd MMM yyyy, hh:mm a').format(booking.timestamp)),
                      
                      if (booking.adminRemarks.isNotEmpty) ...[
                        SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.shade200)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Admin Remarks:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 12)),
                              Text(booking.adminRemarks, style: GoogleFonts.poppins(color: Colors.amber.shade900, fontSize: 13)),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade900),
          SizedBox(width: 10),
          Text("$label: ", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': 
      case 'approve': 
        return Colors.green;
      case 'rejected': 
      case 'reject': 
        return Colors.red;
      case 'processed': 
      case 'process': 
        return Colors.blue;
      default: return Colors.orange;
    }
  }
}
