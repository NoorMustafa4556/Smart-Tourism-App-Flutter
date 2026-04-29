import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Models/PlaceModel.dart';
import 'BookingDetailsFormScreen.dart';
import '../Services/DatabaseService.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final PlaceModel place;
  PlaceDetailsScreen({required this.place});

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  String selectedCategory = 'Individual';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.place.name),
              background: CachedNetworkImage(
                imageUrl: DatabaseService.getCORSProxyUrl(widget.place.image), 
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.blue.shade900),
                errorWidget: (context, url, error) => Container(
                  color: Colors.blue.shade900,
                  child: Center(child: Icon(Icons.error, color: Colors.white)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(widget.place.description),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsFormScreen(
                            place: widget.place,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("CONTINUE TO BOOKING", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
