class BookingModel {
  final String bookingId;
  final String userId;
  final String userName;
  final String placeName;
  final String category; // Family, Individual, Friends
  final String paymentScreenshot;
  final String status; // pending, approved, rejected
  final DateTime timestamp;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.placeName,
    required this.category,
    required this.paymentScreenshot,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'placeName': placeName,
      'category': category,
      'paymentScreenshot': paymentScreenshot,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      placeName: map['placeName'] ?? '',
      category: map['category'] ?? '',
      paymentScreenshot: map['paymentScreenshot'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
