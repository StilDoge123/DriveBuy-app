import 'package:equatable/equatable.dart';

class CarAd extends Equatable {
  final int id;
  final String userId;
  final String make;
  final String model;
  final String title;
  final String description;
  final int year;
  final String color;
  final int horsepower;
  final int displacement;
  final int mileage;
  final int price;
  final String doorCount;
  final int ownerCount;
  final String phone;
  final String? region;
  final String? city;
  final List<String> imageUrls;
  final List<String> features;
  final String? transmissionType;
  final String? fuelType;
  final String? bodyType;
  final String? steeringPosition;
  final String? cylinderCount;
  final String? driveType;
  final String? carCondition;
  final DateTime? createdAt;

  const CarAd({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.title,
    required this.description,
    required this.year,
    required this.color,
    required this.horsepower,
    required this.displacement,
    required this.mileage,
    required this.price,
    required this.doorCount,
    required this.ownerCount,
    required this.phone,
    this.region,
    this.city,
    required this.imageUrls,
    required this.features,
    this.transmissionType,
    this.fuelType,
    this.bodyType,
    this.steeringPosition,
    this.cylinderCount,
    this.driveType,
    this.carCondition,
    this.createdAt,
  });

  factory CarAd.fromJson(Map<String, dynamic> json) {
    return CarAd(
      id: json['id'] as int,
      userId: json['userId'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      year: json['year'] as int,
      color: json['color'] as String,
      horsepower: json['hp'] as int,
      displacement: json['displacement'] as int,
      mileage: json['mileage'] as int,
      price: json['price'] as int,
      doorCount: json['doorCount'] as String,
      ownerCount: json['ownerCount'] as int,
      phone: json['phone'] as String,
      region: json['region'] as String?,
      city: json['city'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      transmissionType: json['transmissionType'] as String?,
      fuelType: json['fuelType'] as String?,
      bodyType: json['bodyType'] as String?,
      steeringPosition: json['steeringPosition'] as String?,
      cylinderCount: json['cylinderCount'] as String?,
      driveType: json['driveType'] as String?,
      carCondition: json['condition'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'horsepower': horsepower,
      'displacement': displacement,
      'mileage': mileage,
      'price': price,
      'doorCount': doorCount,
      'ownerCount': ownerCount,
      'phone': phone,
      'region': region,
      'city': city,
      'imageUrls': imageUrls,
      'features': features,
      'description': description,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'bodyType': bodyType,
      'steeringPosition': steeringPosition,
      'cylinderCount': cylinderCount,
      'driveType': driveType,
      'condition': carCondition,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        make,
        model,
        title,
        description,
        year,
        color,
        horsepower,
        displacement,
        mileage,
        price,
        doorCount,
        ownerCount,
        phone,
        region,
        city,
        imageUrls,
        features,
        transmissionType,
        fuelType,
        bodyType,
        steeringPosition,
        cylinderCount,
        driveType,
        carCondition,
        createdAt,
      ];
} 