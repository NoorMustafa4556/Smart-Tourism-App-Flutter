import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';
import '../Models/PlaceModel.dart';
import 'PlaceDetailsScreen.dart';
import 'MyBookingsScreen.dart';
import 'ProfileSetupScreen.dart';
import 'WelcomeScreen.dart';
import 'TripPlanScreen.dart';
import '../Services/NotificationService.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Initialize Notification Listeners
    NotificationService().initialize(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF000428), Color(0xFF004E92)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("SMART TOURISM", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      drawer: _buildDrawer(context, user, authProvider),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchSection(),
          Expanded(
            child: StreamBuilder<List<PlaceModel>>(
              stream: _db.getPlaces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Colors.blue.shade900));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No places found.", style: TextStyle(color: Colors.grey)));

                final places = snapshot.data!.where((p) => 
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                  p.location.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (places.isEmpty) return Center(child: Text("No matches found for '$_searchQuery'", style: TextStyle(color: Colors.grey)));
                
                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return _buildPlaceGridCard(context, place);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: user?.profilePic != null && user!.profilePic.isNotEmpty 
                    ? CachedNetworkImageProvider(DatabaseService.getCORSProxyUrl(user.profilePic)) 
                    : null,
                child: user?.profilePic == null || user!.profilePic.isEmpty ? Icon(Icons.person, color: Colors.grey) : null,
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Need a Vacation?", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                  Text(user?.name ?? 'Traveler', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search destinations...",
              prefixIcon: Icon(Icons.search, color: Colors.blue.shade900),
              suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(icon: Icon(Icons.clear), onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    })
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceGridCard(BuildContext context, PlaceModel place) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceDetailsScreen(place: place))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade50, // Matches the light pink/red background of the blood app
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: DatabaseService.getCORSProxyUrl(place.image), 
                  height: 40, 
                  width: 40, 
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Icon(Icons.image, color: Colors.grey),
                  errorWidget: (context, url, error) => Icon(Icons.location_city, color: Colors.red.shade700, size: 40),
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              place.name,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              "Rs. ${place.price.toInt()}",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, user, authProvider) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.profilePic != null && user!.profilePic.isNotEmpty 
                  ? CachedNetworkImageProvider(DatabaseService.getCORSProxyUrl(user.profilePic)) 
                  : null,
              child: user?.profilePic == null || user!.profilePic.isEmpty ? Icon(Icons.person, size: 40, color: Colors.blue.shade900) : null,
            ),
            accountName: Text(user?.name ?? "Traveler", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            accountEmail: Text(user?.email ?? "", style: TextStyle(color: Colors.white70)),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF000428), Color(0xFF004E92)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          _buildDrawerItem(Icons.history, "My Bookings", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyBookingsScreen()));
          }),
          _buildDrawerItem(Icons.map_outlined, "Trip Plans", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => TripPlanScreen()));
          }),
          _buildDrawerItem(Icons.person_outline, "My Profile", () {
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
