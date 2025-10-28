class Medicine {
  final String medicineId;
  final String name;
  final String genericName;
  final String medicineType;
  final String manufacturer;
  final String description;
  final String activeIngredient;

  Medicine({
    required this.medicineId,
    required this.name,
    required this.genericName,
    required this.medicineType,
    required this.manufacturer,
    required this.description,
    required this.activeIngredient,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineId: json['medicine_id'],
      name: json['name'],
      genericName: json['generic_name'],
      medicineType: json['medicine_type'],
      manufacturer: json['manufacturer'],
      description: json['description'],
      activeIngredient: json['active_ingredient'],
    );
  }
}