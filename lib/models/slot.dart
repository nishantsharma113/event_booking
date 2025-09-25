// slot.dart
class Slot {
  final String id;
  final String turfId;
  final DateTime date;
  final String timeRange;
  final double price;
  final bool isBooked;

  Slot({
    required this.id,
    required this.turfId,
    required this.date,
    required this.timeRange,
    required this.price,
    required this.isBooked,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        id: json['id'],
        turfId: json['turf_id'],
        date: DateTime.parse(json['date']),
        timeRange: json['time_range'],
        price: (json['price'] as num).toDouble(),
        isBooked: json['is_booked'] ?? false,
      );
}
