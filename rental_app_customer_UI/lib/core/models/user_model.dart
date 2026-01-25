class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? role;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
    };
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
    );
  }
}
