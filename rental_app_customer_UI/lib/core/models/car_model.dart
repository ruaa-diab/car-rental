import 'branch_model.dart';

class CarModel {
  final int id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final String type;
  final String transmission;
  final String fuel;
  final double pricePerDay;
  final int seats;
  final String? color;
  final String? licensePlate;
  final String imageUrl;
  final List<String> additionalImages;
  final double rating;
  final int reviewCount;
  final int totalQuantity;
  final int availableQuantity;
  final String? description;
  final List<String> features;
  final List<BranchModel>? branches;
  final bool isFavorite;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.type,
    required this.transmission,
    required this.fuel,
    required this.pricePerDay,
    required this.seats,
    this.color,
    this.licensePlate,
    required this.imageUrl,
    this.additionalImages = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.totalQuantity,
    required this.availableQuantity,
    this.description,
    this.features = const [],
    this.branches,
    this.isFavorite = false,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      type: json['type'] ?? 'SEDAN',
      transmission: json['transmission'] ?? 'AUTOMATIC',
      fuel: json['fuel'] ?? 'PETROL',
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      seats: json['seats'] ?? 4,
      color: json['color'],
      licensePlate: json['licensePlate'],
      imageUrl: json['imageUrl'] ?? '',
      additionalImages: json['additionalImages'] != null
          ? List<String>.from(json['additionalImages'])
          : [],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      availableQuantity: json['availableQuantity'] ?? 0,
      description: json['description'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
      branches: json['branches'] != null
          ? (json['branches'] as List)
              .map((b) => BranchModel.fromJson(b))
              .toList()
          : null,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'type': type,
      'transmission': transmission,
      'fuel': fuel,
      'pricePerDay': pricePerDay,
      'seats': seats,
      'color': color,
      'licensePlate': licensePlate,
      'imageUrl': imageUrl,
      'additionalImages': additionalImages,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalQuantity': totalQuantity,
      'availableQuantity': availableQuantity,
      'description': description,
      'features': features,
      'isFavorite': isFavorite,
    };
  }

  // Helper getters for display
  String get displayName => '$brand $model';
  String get transmissionDisplay => transmission == 'AUTOMATIC' ? 'Auto' : 'Manual';
  String get fuelType => fuelDisplay; // Alias for fuelDisplay
  String get fuelDisplay {
    switch (fuel) {
      case 'PETROL': return 'Petrol';
      case 'DIESEL': return 'Diesel';
      case 'ELECTRIC': return 'Electric';
      case 'HYBRID': return 'Hybrid';
      default: return fuel;
    }
  }
  String get typeDisplay {
    switch (type) {
      case 'SEDAN': return 'Sedan';
      case 'SUV': return 'SUV';
      case 'SPORT': return 'Sport';
      case 'ELECTRIC': return 'Electric';
      case 'LUXURY': return 'Luxury';
      case 'COMPACT': return 'Compact';
      case 'VAN': return 'Van';
      default: return type;
    }
  }
  bool get isAvailable => availableQuantity > 0;
}
