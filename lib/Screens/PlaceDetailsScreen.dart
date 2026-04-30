import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Models/PlaceModel.dart';
import 'BookingDetailsFormScreen.dart';
import '../Services/DatabaseService.dart';
import '../Models/ReviewModel.dart';
import '../Models/ItineraryModel.dart';
import 'package:provider/provider.dart';
import '../Providers/AuthProvider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  SizedBox(height: 25),
                  _buildItineraryButton(),
                  SizedBox(height: 30),
                  Divider(),
                  _buildReviewsSection(),
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

  Widget _buildItineraryButton() {
    final authProvider = Provider.of<AuthProvider>(context);
    final db = DatabaseService();

    return StreamBuilder<List<ItineraryModel>>(
      stream: db.getUserItineraries(authProvider.userModel!.uid),
      builder: (context, snapshot) {
        final plans = snapshot.data ?? [];
        return OutlinedButton.icon(
          onPressed: plans.isEmpty 
            ? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Create a Trip Plan first from the menu!")))
            : () => _showAddToPlanDialog(plans),
          icon: Icon(Icons.add_location_alt_outlined),
          label: Text("ADD TO TRIP PLAN"),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            side: BorderSide(color: Colors.blue.shade800),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        );
      },
    );
  }

  void _showAddToPlanDialog(List<ItineraryModel> plans) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select a Trip Plan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 15),
            ...plans.map((plan) => ListTile(
              leading: Icon(Icons.map, color: Colors.blue.shade900),
              title: Text(plan.title),
              onTap: () async {
                if (!plan.spotIds.contains(widget.place.id)) {
                  plan.spotIds.add(widget.place.id);
                  await DatabaseService().createItinerary(plan);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to ${plan.title}!")));
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Already in this plan.")));
                }
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final db = DatabaseService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Reviews", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: _showAddReviewDialog, child: Text("Add Review")),
          ],
        ),
        StreamBuilder<List<ReviewModel>>(
          stream: db.getSpotReviews(widget.place.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No reviews yet. Be the first!", style: TextStyle(color: Colors.grey))),
              );
            }
            final reviews = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: review.userProfilePic.isNotEmpty 
                        ? NetworkImage(DatabaseService.getCORSProxyUrl(review.userProfilePic)) 
                        : null,
                    child: review.userProfilePic.isEmpty ? Icon(Icons.person) : null,
                  ),
                  title: Row(
                    children: [
                      Text(review.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Spacer(),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(review.rating.toString(), style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.comment, style: TextStyle(fontSize: 13, color: Colors.black87)),
                      Text(DateFormat('dd MMM yyyy').format(review.timestamp), style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                );
              },
            );
          },
        )
      ],
    );
  }

  void _showAddReviewDialog() {
    double _rating = 5.0;
    final _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Write a Review", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Rating: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<double>(
                    value: _rating,
                    items: [1.0, 2.0, 3.0, 4.0, 5.0].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                    onChanged: (val) => setDialogState(() => _rating = val!),
                  ),
                  Icon(Icons.star, color: Colors.amber),
                ],
              ),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(hintText: "Your experience...", border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (_commentController.text.isEmpty) return;
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final review = ReviewModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  spotId: widget.place.id,
                  userId: authProvider.userModel!.uid,
                  userName: authProvider.userModel!.name,
                  userProfilePic: authProvider.userModel!.profilePic,
                  rating: _rating,
                  comment: _commentController.text.trim(),
                  timestamp: DateTime.now(),
                );
                await DatabaseService().addReview(review);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Review added!")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white),
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }

}
