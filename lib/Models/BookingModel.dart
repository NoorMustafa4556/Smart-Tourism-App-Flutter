class BookingModel {
  final String bookingId;
  final String userId;
  final String userName;
  final String email;
  final String phone;
  final String placeName;
  final String category; // Family, Individual, Friends
  final int persons;
  final int days;
  final double totalPrice;
  final String paymentMethod;
  final String paymentScreenshot;
  final String status; // pending, approved, processed, rejected
  final String adminRemarks;
  final DateTime timestamp;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.placeName,
    required this.category,
    required this.persons,
    required this.days,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentScreenshot,
    required this.status,
    required this.adminRemarks,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'email': email,
      'phone': phone,
      'placeName': placeName,
      'category': category,
      'persons': persons,
      'days': days,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'paymentScreenshot': paymentScreenshot,
      'status': status,
      'adminRemarks': adminRemarks,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      placeName: map['placeName'] ?? '',
      category: map['category'] ?? '',
      persons: map['persons'] ?? 1,
      days: map['days'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      paymentScreenshot: map['paymentScreenshot'] ?? '',
      status: map['status'] ?? 'pending',
      adminRemarks: map['adminRemarks'] ?? '',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] is String 
              ? DateTime.parse(map['timestamp']) 
              : (map['timestamp'] as dynamic).toDate())
          : DateTime.now(),
    );
  }
}
