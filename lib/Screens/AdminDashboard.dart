import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginScreen.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("ADMIN DASHBOARD", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber.shade900,
        actions: [
          IconButton(icon: Icon(Icons.logout, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()))),
        ],
      ),
      body: Center(
        child: Text("Welcome to VIP Admin Panel\n(Manage Bookings Here)", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
      ),
    );
  }
}
