import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Models/BookingModel.dart';
import '../Models/PlaceModel.dart';
import '../Models/PaymentMethodModel.dart';
import '../Services/DatabaseService.dart';
import 'AdminAddPlaceScreen.dart';
import 'LoginScreen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Admin Panel", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber.shade900,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()))),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.book_online), text: "Bookings"),
            Tab(icon: Icon(Icons.place), text: "Places"),
            Tab(icon: Icon(Icons.payment), text: "Payments"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsTab(),
          _buildPlacesTab(),
          _buildPaymentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAddPlaceScreen()));
          } else if (_tabController.index == 2) {
            _showPaymentMethodDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Select Places or Payments tab to add items.")));
          }
        },
        backgroundColor: Colors.amber.shade900,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Add New", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // --- BOOKINGS TAB ---
  Widget _buildBookingsTab() {
    return StreamBuilder<List<BookingModel>>(
      stream: _db.getAllBookings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No bookings found."));

        final bookings = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 15),
              child: ExpansionTile(
                title: Text("${booking.userName} - ${booking.placeName}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text("Status: ${booking.status.toUpperCase()} | Rs. ${booking.totalPrice}", style: TextStyle(color: _getStatusColor(booking.status))),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Phone: ${booking.phone}"),
                        Text("Email: ${booking.email}"),
                        Text("Details: ${booking.persons} Persons, ${booking.days} Days (${booking.category})"),
                        Text("Payment: ${booking.paymentMethod}"),
                        Text("Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(booking.timestamp)}"),
                        SizedBox(height: 10),
                        Text("Payment Proof:", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        booking.paymentScreenshot.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _showImageDialog(booking.paymentScreenshot),
                                child: Image.network(
                                  DatabaseService.getCORSProxyUrl(booking.paymentScreenshot), 
                                  height: 150, 
                                  width: double.infinity, 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: Center(child: Text("CORS Error: View on Mobile", style: TextStyle(color: Colors.grey))),
                                  ),
                                ),
                              )
                            : Text("No screenshot provided.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(booking, "Approve", Colors.green),
                            _buildActionButton(booking, "Reject", Colors.red),
                            _buildActionButton(booking, "Process", Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- PLACES TAB ---
  Widget _buildPlacesTab() {
    return StreamBuilder<List<PlaceModel>>(
      stream: _db.getPlaces(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No places found. Add one!"));

        final places = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: place.image.isNotEmpty 
                    ? CircleAvatar(backgroundImage: NetworkImage(DatabaseService.getCORSProxyUrl(place.image)))
                    : CircleAvatar(child: Icon(Icons.place)),
                title: Text(place.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text("Rs. ${place.price.toInt()} | ${place.location}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAddPlaceScreen(placeToEdit: place))),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation("Place", () => _db.deletePlace(place.id)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- PAYMENTS TAB ---
  Widget _buildPaymentsTab() {
    return StreamBuilder<List<PaymentMethodModel>>(
      stream: _db.getPaymentMethods(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No payment methods found. Add one!"));

        final methods = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, color: Colors.green),
                title: Text(method.methodName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text("${method.accountTitle}\n${method.accountNumber}"),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showPaymentMethodDialog(methodToEdit: method),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation("Payment Method", () => _db.deletePaymentMethod(method.id)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- HELPERS ---
  Color _getStatusColor(String status) {
    if (status == 'approved') return Colors.green;
    if (status == 'rejected') return Colors.red;
    if (status == 'processed') return Colors.blue;
    return Colors.orange;
  }

  void _showImageDialog(String imageUrl) {
    showDialog(context: context, builder: (context) => Dialog(
      child: Image.network(
        DatabaseService.getCORSProxyUrl(imageUrl), 
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 300,
          color: Colors.grey.shade200,
          child: Center(child: Text("CORS Error: Image blocked on Web.", style: TextStyle(color: Colors.grey))),
        ),
      )
    ));
  }

  Widget _buildActionButton(BookingModel booking, String newStatus, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 10)),
      onPressed: () => _showStatusDialog(booking, newStatus.toLowerCase()),
      child: Text(newStatus),
    );
  }

  void _showStatusDialog(BookingModel booking, String newStatus) {
    final TextEditingController remarksController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update to ${newStatus.toUpperCase()}"),
          content: TextField(controller: remarksController, decoration: InputDecoration(labelText: "Admin Remarks (Optional)", border: OutlineInputBorder()), maxLines: 3),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _db.updateBookingStatus(booking.bookingId, newStatus, remarksController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking updated to $newStatus")));
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(String itemName, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $itemName?"),
        content: Text("Are you sure you want to delete this $itemName? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$itemName deleted.")));
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog({PaymentMethodModel? methodToEdit}) {
    final nameController = TextEditingController(text: methodToEdit?.methodName ?? "");
    final titleController = TextEditingController(text: methodToEdit?.accountTitle ?? "");
    final numberController = TextEditingController(text: methodToEdit?.accountNumber ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(methodToEdit == null ? "Add Payment Method" : "Edit Payment Method"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Method Name (e.g. Jazz Cash)")),
              SizedBox(height: 10),
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Account Title")),
              SizedBox(height: 10),
              TextField(controller: numberController, decoration: InputDecoration(labelText: "Account Number")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || titleController.text.isEmpty || numberController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fill all fields")));
                return;
              }
              final method = PaymentMethodModel(
                id: methodToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                methodName: nameController.text.trim(),
                accountTitle: titleController.text.trim(),
                accountNumber: numberController.text.trim(),
              );
              
              if (methodToEdit == null) {
                await _db.addPaymentMethod(method);
              } else {
                await _db.updatePaymentMethod(method);
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Method Saved")));
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
