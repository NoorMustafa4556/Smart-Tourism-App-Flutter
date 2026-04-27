import 'package:flutter/material.dart';
import '../Models/BookingModel.dart';
import '../Services/DatabaseService.dart';

class AdminDashboard extends StatelessWidget {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _db.getPendingBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No pending bookings"));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("${booking.userName} - ${booking.placeName}"),
                  subtitle: Text("Category: ${booking.category}"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => _showBookingDetails(context, booking),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBookingDetails(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Booking Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Divider(),
              Text("User: ${booking.userName}"),
              Text("Place: ${booking.placeName}"),
              Text("Category: ${booking.category}"),
              SizedBox(height: 20),
              Text("Payment Screenshot:", style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Image.network(
                  booking.paymentScreenshot,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(child: Text("Image Error")),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _db.updateBookingStatus(booking.bookingId, "approved");
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: Text("Approve"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _db.updateBookingStatus(booking.bookingId, "rejected");
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    child: Text("Reject"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
