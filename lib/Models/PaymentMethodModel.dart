class PaymentMethodModel {
  final String id;
  final String methodName;
  final String accountTitle;
  final String accountNumber;

  PaymentMethodModel({
    required this.id,
    required this.methodName,
    required this.accountTitle,
    required this.accountNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'methodName': methodName,
      'accountTitle': accountTitle,
      'accountNumber': accountNumber,
    };
  }

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentMethodModel(
      id: docId,
      methodName: map['methodName'] ?? '',
      accountTitle: map['accountTitle'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethodModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
