import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Models/ItineraryModel.dart';
import '../Models/PlaceModel.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';
import 'PlaceDetailsScreen.dart';

class TripPlanScreen extends StatefulWidget {
  @override
  _TripPlanScreenState createState() => _TripPlanScreenState();
}

class _TripPlanScreenState extends State<TripPlanScreen> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Trip Plans", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF004E92),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<ItineraryModel>>(
        stream: _db.getUserItineraries(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey.shade300),
                  SizedBox(height: 15),
                  Text("No trip plans yet. Start adding spots!", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          final plans = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _buildPlanCard(plan);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePlanDialog,
        backgroundColor: Color(0xFF004E92),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("New Trip", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPlanCard(ItineraryModel plan) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text(plan.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text("${plan.spotIds.length} spots saved", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        children: [
          StreamBuilder<List<PlaceModel>>(
            stream: _db.getPlaces(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              final spots = snapshot.data!.where((p) => plan.spotIds.contains(p.id)).toList();
              
              return Column(
                children: [
                  ...spots.map((spot) => ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(DatabaseService.getCORSProxyUrl(spot.image))),
                    title: Text(spot.name, style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceDetailsScreen(place: spot))),
                  )).toList(),
                  TextButton.icon(
                    onPressed: () => _db.deleteItinerary(plan.id),
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    label: Text("Delete Plan", style: TextStyle(color: Colors.red)),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }

  void _showCreatePlanDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create New Trip Plan"),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: "Trip Name (e.g. Summer Vacation)", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final newPlan = ItineraryModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: authProvider.userModel!.uid,
                title: titleController.text.trim(),
                spotIds: [],
                createdAt: DateTime.now(),
              );
              await _db.createItinerary(newPlan);
              Navigator.pop(context);
            },
            child: Text("Create"),
          )
        ],
      ),
    );
  }
}
