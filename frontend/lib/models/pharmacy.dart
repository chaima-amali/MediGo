class Pharmacy {
  final String pharmacyId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String openingHours;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  bool? inStock;
  double? price;
  double? distance;

  Pharmacy({
    required this.pharmacyId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.openingHours,
    required this.rating,
    required this.totalReviews,
    required this.isVerified,
    this.inStock,
    this.price,
    this.distance,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      pharmacyId: json['pharmacy_id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      phoneNumber: json['phone_number'],
      openingHours: json['opening_hours'],
      rating: json['rating'].toDouble(),
      totalReviews: json['total_reviews'],
      isVerified: json['is_verified'],
      inStock: json['in_stock'],
      price: json['price']?.toDouble(),
      distance: json['distance']?.toDouble(),
    );
  }

  String getDistanceText() {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).round()}m away';
    }
    return '${distance!.toStringAsFixed(1)}km away';
  }
}