// booking.dart
class Booking {
  final String id;
  final String turfId;
  final String userId;
  final String slotId;
  final String status;
  final double totalPrice;
  final DateTime? bookedAt;

  Booking({
    required this.id,
    required this.turfId,
    required this.userId,
    required this.slotId,
    required this.status,
    required this.totalPrice,
    this.bookedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    turfId: json['turf_id'],
    userId: json['user_id'],
    slotId: json['slot_id'],
    status: json['status'],
    totalPrice: (json['total_price'] as num).toDouble(),
    bookedAt: json['booked_at'] != null
        ? DateTime.tryParse(json['booked_at'])
        : null,
  );
}
