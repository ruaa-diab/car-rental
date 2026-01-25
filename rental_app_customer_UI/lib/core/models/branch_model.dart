class BranchModel {
  final int id;
  final String name;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final String? openingTime;
  final String? closingTime;
  final bool isActive;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.openingTime,
    this.closingTime,
    this.isActive = true,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phone: json['phone'],
      email: json['email'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isActive': isActive,
    };
  }

  String get fullAddress => '$address, $city, $country';

  @override
  String toString() => name;
}
