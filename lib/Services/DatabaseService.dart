import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../Models/BookingModel.dart';
import '../Models/PlaceModel.dart';
import '../Models/PaymentMethodModel.dart';
import '../Models/ItineraryModel.dart';
import '../Models/ReviewModel.dart';
import '../Models/HotelModel.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream of Places
  Stream<List<PlaceModel>> getPlaces() {
    return _firestore.collection('places').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PlaceModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Upload Image (Web & Mobile Compatible)
  Future<String> uploadImage(XFile imageFile, String path) async {
    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = _storage.ref().child(path).child(fileName);
      
      // Start upload using bytes (Works on Web and Mobile)
      final bytes = await imageFile.readAsBytes();
      UploadTask uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      
      // Wait for completion
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      
      // Get URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw "Upload failed: $e";
    }
  }

  // Admin: Create Place
  Future<void> createPlace(PlaceModel place) async {
    await _firestore.collection('places').doc(place.id).set(place.toMap());
  }

  // Admin: Update Place
  Future<void> updatePlace(PlaceModel place) async {
    await _firestore.collection('places').doc(place.id).update(place.toMap());
  }

  // Admin: Delete Place
  Future<void> deletePlace(String placeId) async {
    await _firestore.collection('places').doc(placeId).delete();
  }

  // Book a Place
  Future<void> createBooking(BookingModel booking) async {
    await _firestore.collection('bookings').doc(booking.bookingId).set(booking.toMap());
  }

  // Get User Bookings
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data())).toList();
    });
  }

  // Admin: Get All Pending Bookings
  Stream<List<BookingModel>> getPendingBookings() {
    return _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data())).toList();
    });
  }

  // Admin: Get All Bookings
  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data())).toList();
    });
  }

  // Admin: Update Booking Status & Remarks
  Future<void> updateBookingStatus(String bookingId, String status, String remarks) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'adminRemarks': remarks,
    });
  }

  // Payment Methods CRUD
  Stream<List<PaymentMethodModel>> getPaymentMethods() {
    return _firestore.collection('payment_methods').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PaymentMethodModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addPaymentMethod(PaymentMethodModel method) async {
    await _firestore.collection('payment_methods').doc(method.id).set(method.toMap());
  }

  Future<void> updatePaymentMethod(PaymentMethodModel method) async {
    await _firestore.collection('payment_methods').doc(method.id).update(method.toMap());
  }

  Future<void> deletePaymentMethod(String methodId) async {
    await _firestore.collection('payment_methods').doc(methodId).delete();
  }

  // --- Admin Profile ---
  Stream<Map<String, dynamic>?> getAdminProfile() {
    return _firestore.collection('admin_settings').doc('profile').snapshots().map((doc) => doc.data());
  }

  Future<void> updateAdminProfile(String name, String profilePicUrl) async {
    await _firestore.collection('admin_settings').doc('profile').set({
      'name': name,
      'profilePic': profilePicUrl,
    }, SetOptions(merge: true));
  }

  // Helper to bypass Web CORS for images since native configuration failed
  static String getCORSProxyUrl(String url) {
    if (kIsWeb && url.startsWith('http')) {
      return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
    }
    return url;
  }

  // --- Itinerary Methods ---
  Future<void> createItinerary(ItineraryModel itinerary) async {
    await _firestore.collection('itineraries').doc(itinerary.id).set(itinerary.toMap());
  }

  Stream<List<ItineraryModel>> getUserItineraries(String userId) {
    return _firestore
        .collection('itineraries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ItineraryModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> deleteItinerary(String id) async {
    await _firestore.collection('itineraries').doc(id).delete();
  }

  // --- Review Methods ---
  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('reviews').doc(review.id).set(review.toMap());
  }

  Stream<List<ReviewModel>> getSpotReviews(String spotId) {
    return _firestore
        .collection('reviews')
        .where('spotId', isEqualTo: spotId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data())).toList();
    });
  }

  // --- Hotel Methods ---
  Future<void> createHotel(HotelModel hotel) async {
    await _firestore.collection('hotels').doc(hotel.id).set(hotel.toMap());
  }

  Stream<List<HotelModel>> getSpotHotels(String spotId) {
    return _firestore
        .collection('hotels')
        .where('spotId', isEqualTo: spotId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => HotelModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> deleteHotel(String hotelId) async {
    await _firestore.collection('hotels').doc(hotelId).delete();
  }

  Future<void> updateHotel(HotelModel hotel) async {
    await _firestore.collection('hotels').doc(hotel.id).update(hotel.toMap());
  }

  // Admin: Get All Hotels
  Stream<List<HotelModel>> getHotels() {
    return _firestore.collection('hotels').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => HotelModel.fromMap(doc.data())).toList();
    });
  }
}
