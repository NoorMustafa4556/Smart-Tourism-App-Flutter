import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Auth/WelcomeScreen.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';
import '../Models/PlaceModel.dart';
import 'PlaceDetailsScreen.dart';
import 'MyBookingsScreen.dart';
import '../Auth/ProfileSetupScreen.dart';

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
  String _selectedCategory = "All";
  final List<Map<String, dynamic>> _categories = [
    {"name": "All", "icon": Icons.apps},
    {"name": "Mountains", "icon": Icons.landscape},
    {"name": "Beaches", "icon": Icons.beach_access},
    {"name": "Historical", "icon": Icons.account_balance},
    {"name": "Nature", "icon": Icons.forest},
  ];
  late Stream<List<PlaceModel>> _placesStream;

  @override
  void initState() {
    super.initState();
    _placesStream = _db.getPlaces();
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
        children: [
          _buildSearchSection(),
          _buildCategoriesSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Popular Destinations", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text("See All")),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PlaceModel>>(
              stream: _placesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                final places = snapshot.data?.where((p) {
                  final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || p.location.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCategory = _selectedCategory == "All" || p.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList() ?? [];

                if (places.isEmpty) return Center(child: Text("No matches found."));

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: places.length,
                  itemBuilder: (context, index) => _buildPlaceCard(context, places[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome,", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
              Text("Explore the World", style: GoogleFonts.poppins(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade900,
            backgroundImage: user?.profilePic != null && user!.profilePic.isNotEmpty 
                ? CachedNetworkImageProvider(DatabaseService.getCORSProxyUrl(user.profilePic)) 
                : null,
            child: user?.profilePic == null || user!.profilePic.isEmpty ? Icon(Icons.person, color: Colors.white) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Search destinations, hotels...",
          prefixIcon: Icon(Icons.search, color: Colors.blue.shade900),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300)),
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['name']),
            child: Container(
              width: 85,
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF004E92) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? Color(0xFF004E92).withOpacity(0.3) : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(cat['icon'], color: isSelected ? Colors.white : Colors.grey.shade600, size: 28),
                  ),
                  SizedBox(height: 8),
                  Text(
                    cat['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Color(0xFF004E92) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, PlaceModel place) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceDetailsScreen(place: place))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: DatabaseService.getCORSProxyUrl(place.image),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) => Icon(Icons.broken_image),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                      child: Text("Rs. ${place.price.toInt()}", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF004E92), size: 12),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
