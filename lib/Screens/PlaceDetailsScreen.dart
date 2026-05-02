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
import '../Models/HotelModel.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final PlaceModel place;
  PlaceDetailsScreen({required this.place});

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  String selectedCategory = 'Individual';
  HotelModel? selectedHotel;
  int stayDays = 1;
  late Stream<List<HotelModel>> _hotelsStream;

  @override
  void initState() {
    super.initState();
    _hotelsStream = DatabaseService().getSpotHotels(widget.place.id);
  }

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
                  _buildHotelsSection(),
                  SizedBox(height: 30),
                  _buildDurationSection(),
                  SizedBox(height: 30),
                  _buildRelatedPlacesSection(),
                  SizedBox(height: 30),
                  Divider(),
                  _buildReviewsSection(),
                  SizedBox(height: 50),
                  _buildBookingButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsSection() {
    final db = DatabaseService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nearby Accommodation", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          height: 180,
          child: StreamBuilder<List<HotelModel>>(
            stream: _hotelsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              if (snapshot.data!.isEmpty) return Center(child: Text("No hotels listed for this spot.", style: TextStyle(color: Colors.grey)));
              
              final hotels = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  final isSelected = selectedHotel?.id == hotel.id;
                  return GestureDetector(
                    onTap: () => setState(() => selectedHotel = hotel),
                    child: Container(
                      width: 150,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isSelected ? Colors.blue.shade900 : Colors.grey.shade300, width: 2),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                            child: CachedNetworkImage(
                              imageUrl: DatabaseService.getCORSProxyUrl(hotel.image),
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hotel.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text("Rs. ${hotel.pricePerNight.toInt()}/night", style: TextStyle(fontSize: 10, color: Colors.blue.shade900)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Stay Duration", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          children: [
            _durationBtn(Icons.remove, () { if(stayDays > 1) setState(() => stayDays--); }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("$stayDays Days", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _durationBtn(Icons.add, () => setState(() => stayDays++)),
          ],
        ),
      ],
    );
  }

  Widget _durationBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.blue.shade900),
      ),
    );
  }

  Widget _buildBookingButton() {
    double totalPrice = widget.place.price + (selectedHotel?.pricePerNight ?? 0) * stayDays;
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsFormScreen(
              place: widget.place,
              hotel: selectedHotel,
              totalDays: stayDays,
              totalPrice: totalPrice,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Column(
        children: [
          Text("CONTINUE TO BOOKING", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Total Est: Rs. ${totalPrice.toInt()}", style: TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildItineraryButton() {
    final authProvider = Provider.of<AuthProvider>(context);
    final db = DatabaseService();

    if (authProvider.userModel == null) return SizedBox();

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
                if (authProvider.userModel == null) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please login to add review")));
                   return;
                }
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

  Widget _buildRelatedPlacesSection() {
    final db = DatabaseService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Discover More ${widget.place.category}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          height: 180,
          child: StreamBuilder<List<PlaceModel>>(
            stream: db.getPlaces(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              final related = snapshot.data!.where((p) => p.category == widget.place.category && p.id != widget.place.id).toList();
              if (related.isEmpty) return Text("No other spots in this category.", style: TextStyle(color: Colors.grey, fontSize: 12));
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: related.length,
                itemBuilder: (context, index) {
                  final spot = related[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PlaceDetailsScreen(place: spot))),
                    child: Container(
                      width: 140,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(DatabaseService.getCORSProxyUrl(spot.image)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(spot.name, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
