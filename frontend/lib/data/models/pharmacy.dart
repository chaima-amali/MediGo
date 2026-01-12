class Pharmacy {
  final int? pharmacyId;
  final String name;
  final double? latitude;
  final double? longitude;
  final String phone;
  final String openingHours;
  final double rating;
  final String? imageUrl;
  final String? address;

  Pharmacy({
    this.pharmacyId,
    required this.name,
    this.latitude,
    this.longitude,
    required this.phone,
    required this.openingHours,
    required this.rating,
    this.imageUrl,
    this.address,
  });

  Pharmacy copyWith({
    int? pharmacyId,
    String? name,
    double? latitude,
    double? longitude,
    String? phone,
    String? openingHours,
    double? rating,
    String? imageUrl,
    String? address,
  }) {
    return Pharmacy(
      pharmacyId: pharmacyId ?? this.pharmacyId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
    );
  }

  factory Pharmacy.fromMap(Map<String, dynamic> map) {
    return Pharmacy(
      pharmacyId: map['pharmacy_id'] as int?,
      name: map['name'] as String,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      phone: map['phone'] as String? ?? '',
      openingHours: map['opening_hours'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] as String?,
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pharmacy_id': pharmacyId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'opening_hours': openingHours,
      'rating': rating,
      'image_url': imageUrl,
      'address': address,
    };
  }
}
