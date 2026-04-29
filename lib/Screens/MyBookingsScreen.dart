import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Models/BookingModel.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';

class MyBookingsScreen extends StatelessWidget {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Bookings", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF004E92),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _db.getUserBookings(authProvider.userModel!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
                  SizedBox(height: 15),
                  Text("You haven't made any bookings yet.", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 15),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(booking.placeName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18))),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: _getStatusColor(booking.status), borderRadius: BorderRadius.circular(20)),
                            child: Text(booking.status.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Divider(height: 25),
                      Text("Details: ${booking.persons} Persons, ${booking.days} Days (${booking.category})", style: GoogleFonts.poppins(fontSize: 13)),
                      SizedBox(height: 5),
                      Text("Amount Paid: Rs. ${booking.totalPrice.toInt()} via ${booking.paymentMethod}", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("Date: ${DateFormat('dd MMM yyyy').format(booking.timestamp)}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      
                      if (booking.adminRemarks.isNotEmpty) ...[
                        SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Admin Remarks:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 12)),
                              SizedBox(height: 5),
                              Text(booking.adminRemarks, style: GoogleFonts.poppins(color: Colors.amber.shade900, fontSize: 13)),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
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
