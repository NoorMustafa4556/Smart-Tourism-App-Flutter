import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../Models/BookingModel.dart';
import '../Models/PlaceModel.dart';
import '../Models/PaymentMethodModel.dart';

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
}
