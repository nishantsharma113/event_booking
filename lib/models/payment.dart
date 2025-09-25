// payment.dart
class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String method;
  final String status;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'],
        bookingId: json['booking_id'],
        amount: (json['amount'] as num).toDouble(),
        method: json['method'],
        status: json['status'],
      );
}
