class PharmacyMedicine {
  final int? id;
  final int pharmacyId;
  final int medicineFindId;
  final double price;
  final int stock;

  PharmacyMedicine({
    this.id,
    required this.pharmacyId,
    required this.medicineFindId,
    required this.price,
    required this.stock,
  });

  PharmacyMedicine copyWith({
    int? id,
    int? pharmacyId,
    int? medicineFindId,
    double? price,
    int? stock,
  }) {
    return PharmacyMedicine(
      id: id ?? this.id,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      medicineFindId: medicineFindId ?? this.medicineFindId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }

  factory PharmacyMedicine.fromMap(Map<String, dynamic> map) {
    return PharmacyMedicine(
      id: map['id'] as int?,
      pharmacyId: map['pharmacy_id'] as int,
      medicineFindId: map['medicine_find_id'] as int,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: map['stock'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pharmacy_id': pharmacyId,
      'medicine_find_id': medicineFindId,
      'price': price,
      'stock': stock,
    };
  }
}