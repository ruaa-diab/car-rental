// lib/models/employee.dart

class Employee {
  final int id;
  final int? userId;
  final String fullName;
  final String email;
  final String phone;
  final String position;
  final String? department;
  final DateTime? hireDate;
  final String status; // ACTIVE, INACTIVE, ON_LEAVE
  final int? tasksCompleted;
  final double? rating;
  final String? profileImageUrl;
  final DateTime? createdAt;

  Employee({
    required this.id,
    this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.position,
    this.department,
    this.hireDate,
    required this.status,
    this.tasksCompleted,
    this.rating,
    this.profileImageUrl,
    this.createdAt,
  });

  // From JSON (from backend EmployeeResponse)
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: (json['id'] ?? json['employee_id'] ?? 0) as int,
      userId: json['userId'] != null ? (json['userId'] as int) : null,
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      position: json['position'] ?? '',
      department: json['department'],
      hireDate: json['hireDate'] != null
          ? DateTime.parse(json['hireDate'])
          : (json['hire_date'] != null ? DateTime.parse(json['hire_date']) : null),
      status: json['status']?.toString().toUpperCase() ?? 'ACTIVE',
      tasksCompleted: json['tasksCompleted'] ?? json['tasks_completed'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'] ?? json['profile_image'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : null),
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'position': position,
      if (department != null) 'department': department,
      if (hireDate != null) 'hireDate': hireDate!.toIso8601String().split('T')[0],
      'status': status,
      if (tasksCompleted != null) 'tasksCompleted': tasksCompleted,
      if (rating != null) 'rating': rating,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }
}