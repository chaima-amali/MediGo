class User {
  final int? userId;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String gender;
  final String dob;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String premium;

  User({
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.gender,
    required this.dob,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.premium,
  });

  User copyWith({
    int? userId,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? gender,
    String? dob,
    double? latitude,
    double? longitude,
    String? locationName,
    String? premium,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      premium: premium ?? this.premium,
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String,
      gender: map['gender'] as String,
      dob: map['dob'] as String,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationName: map['location_name'] as String?,
      premium: map['premium'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'gender': gender,
      'dob': dob,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'premium': premium,
    };
  }
}