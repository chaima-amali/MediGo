// Models representing Supabase query results for medicines and pharmacy availability
class SupabasePharmacyAvailability {
  final int pharmacyId;
  final String pharmacyName;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? openingHours;
  final double? rating;
  final int stock;
  final double? price;

  SupabasePharmacyAvailability({
    required this.pharmacyId,
    required this.pharmacyName,
    this.latitude,
    this.longitude,
    this.phone,
    this.openingHours,
    this.rating,
    required this.stock,
    this.price,
  });

  bool get inStock => stock > 0;

  factory SupabasePharmacyAvailability.fromMap(Map<String, dynamic> m) {
    final pharmacy = m['pharmacy'] as Map<String, dynamic>? ?? {};
    return SupabasePharmacyAvailability(
      pharmacyId: pharmacy['pharmacy_id'] ?? m['pharmacy_id'] ?? 0,
      pharmacyName: (pharmacy['name'] ?? '') as String,
      latitude: (pharmacy['latitude'] as num?)?.toDouble(),
      longitude: (pharmacy['longitude'] as num?)?.toDouble(),
      phone: pharmacy['phone'] as String?,
      openingHours: pharmacy['opening_hours'] as String?,
      rating: (pharmacy['rating'] as num?)?.toDouble(),
      stock: (m['stock'] as int?) ?? (m['stock'] as num?)?.toInt() ?? 0,
      price: (m['price'] as num?)?.toDouble(),
    );
  }
}

class SupabaseMedicine {
  final int medicineId;
  final String name;
  final String? genericName;
  final String? dosage;
  final String? form;

  // Pharmacies that carry this medicine
  final List<SupabasePharmacyAvailability> availability;

  SupabaseMedicine({
    required this.medicineId,
    required this.name,
    this.genericName,
    this.dosage,
    this.form,
    this.availability = const [],
  });

  factory SupabaseMedicine.fromMap(Map<String, dynamic> m,
      {List<SupabasePharmacyAvailability>? availability}) {
    return SupabaseMedicine(
      medicineId: m['medicine_id'] ?? m['id'] ?? 0,
      name: m['name'] as String? ?? '',
      genericName: m['generic_name'] as String?,
      dosage: m['dosage'] as String?,
      form: m['form'] as String?,
      availability: availability ?? [],
    );
  }
}
