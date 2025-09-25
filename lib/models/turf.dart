// turf.dart
class Turf {
  final String id;
  final String name;
  final String location;
  final double pricePerHour;
  final String? description;
  final List<String>? images;
  final double rating;

  Turf({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerHour,
    this.description,
    this.images,
    this.rating = 0,
  });

  factory Turf.fromJson(Map<String, dynamic> json) => Turf(
        id: json['id'],
        name: json['name'],
        location: json['location'],
        pricePerHour: (json['price_per_hour'] as num).toDouble(),
        description: json['description'],
        images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
        rating: (json['rating'] ?? 0).toDouble(),
      );
}
