import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';
import '../Models/PlaceModel.dart';
import 'PlaceDetailsScreen.dart';
import 'MyBookingsScreen.dart';
import 'ProfileSetupScreen.dart';
import 'WelcomeScreen.dart';

class HomeScreen extends StatelessWidget {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF000428), Color(0xFF004E92)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("VIP TRAVELS", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
      ),
      drawer: _buildVIPDrawer(context, user, authProvider),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: user?.profilePic != null && user!.profilePic.isNotEmpty ? NetworkImage(user.profilePic) : null,
                  child: user?.profilePic == null || user!.profilePic.isEmpty ? Icon(Icons.person) : null,
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello,", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                    Text(user?.name ?? 'Traveler', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("Popular Destinations", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Expanded(
            child: StreamBuilder<List<PlaceModel>>(
              stream: _db.getPlaces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Colors.blue.shade900));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No places found.", style: TextStyle(color: Colors.grey)));

                final places = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return _buildPlaceCard(context, place);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, PlaceModel place) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceDetailsScreen(place: place))),
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 10))],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(place.image, height: 200, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 200, color: Colors.grey.shade200, child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                  ),
                ),
                Positioned(
                  bottom: 15, right: 15,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue.shade900, borderRadius: BorderRadius.circular(12)),
                    child: Text("Rs. ${place.price}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(place.location, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.blue.shade900, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVIPDrawer(BuildContext context, user, authProvider) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.profilePic != null && user!.profilePic.isNotEmpty ? NetworkImage(user.profilePic) : null,
              child: user?.profilePic == null || user!.profilePic.isEmpty ? Icon(Icons.person, size: 40, color: Colors.blue.shade900) : null,
            ),
            accountName: Text(user?.name ?? "VIP Traveler", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            accountEmail: Text(user?.email ?? "", style: TextStyle(color: Colors.white70)),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF000428), Color(0xFF004E92)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          _buildDrawerItem(Icons.history, "My Bookings", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyBookingsScreen()));
          }),
          _buildDrawerItem(Icons.person_outline, "VIP Profile", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSetupScreen()));
          }),
          Divider(),
          Spacer(),
          _buildDrawerItem(Icons.logout, "Logout", () async {
            await authProvider.logout();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WelcomeScreen()), (route) => false);
          }, color: Colors.red),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color == Colors.black87 ? Colors.blue.shade900 : color),
      title: Text(title, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
