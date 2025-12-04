class Pharmacy {
  final int? pharmacyId;
  final String name;
  final String location;
  final String phone;
  final String openingHours;
  final double rating;

  Pharmacy({
    this.pharmacyId,
    required this.name,
    required this.location,
    required this.phone,
    required this.openingHours,
    required this.rating,
  });

  Pharmacy copyWith({
    int? pharmacyId,
    String? name,
    String? location,
    String? phone,
    String? openingHours,
    double? rating,
  }) {
    return Pharmacy(
      pharmacyId: pharmacyId ?? this.pharmacyId,
      name: name ?? this.name,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
    );
  }

  factory Pharmacy.fromMap(Map<String, dynamic> map) {
    return Pharmacy(
      pharmacyId: map['pharmacy_id'] as int?,
      name: map['name'] as String,
      location: map['location'] as String,
      phone: map['phone'] as String,
      openingHours: map['opening_hours'] as String,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pharmacy_id': pharmacyId,
      'name': name,
      'location': location,
      'phone': phone,
      'opening_hours': openingHours,
      'rating': rating,
    };
  }
}