import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Models/BookingModel.dart';
import '../Models/PlaceModel.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream of Places
  Stream<List<PlaceModel>> getPlaces() {
    return _firestore.collection('places').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PlaceModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Upload Payment Screenshot
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = _storage.ref().child(path).child(fileName);
      
      // Start upload
      UploadTask uploadTask = ref.putFile(imageFile);
      
      // Wait for completion
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      
      // Get URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw "Upload failed: $e";
    }
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

  // Admin: Update Booking Status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
  }
}
