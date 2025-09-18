import 'package:equatable/equatable.dart';
import 'car_ad.dart';
import 'user.dart';

class CarAdWithSeller extends Equatable {
  final int id;
  final String? title;
  final String? description;
  final String make;
  final String model;
  final int year;
  final String? color;
  final int hp;
  final int displacement;
  final int mileage;
  final int price;
  final String? bodyType;
  final String? condition;
  final String? doorCount;
  final String? cylinderCount;
  final String? transmissionType;
  final String? fuelType;
  final String? steeringPosition;
  final String? driveType;
  final int ownerCount;
  final String? phone;
  final String? region;
  final String? city;
  final List<String> imageUrls;
  final List<String> features;
  final DateTime createdAt;
  final User seller;

  const CarAdWithSeller({
    required this.id,
    this.title,
    this.description,
    required this.make,
    required this.model,
    required this.year,
    this.color,
    required this.hp,
    required this.displacement,
    required this.mileage,
    required this.price,
    this.bodyType,
    this.condition,
    this.doorCount,
    this.cylinderCount,
    this.transmissionType,
    this.fuelType,
    this.steeringPosition,
    this.driveType,
    required this.ownerCount,
    this.phone,
    this.region,
    this.city,
    required this.imageUrls,
    required this.features,
    required this.createdAt,
    required this.seller,
  });

  // Convert to the original CarAd model for backward compatibility
  CarAd toCarAd() {
    return CarAd(
      id: id,
      userId: seller.id,
      make: make,
      model: model,
      title: title ?? '',
      description: description ?? '',
      year: year,
      color: color ?? '',
      horsepower: hp,
      displacement: displacement,
      mileage: mileage,
      price: price,
      doorCount: doorCount ?? '',
      ownerCount: ownerCount,
      phone: phone ?? '',
      region: region,
      city: city,
      imageUrls: imageUrls,
      features: features,
      transmissionType: transmissionType,
      fuelType: fuelType,
      bodyType: bodyType,
        steeringPosition: steeringPosition,
        cylinderCount: cylinderCount,
        driveType: driveType,
      carCondition: condition,
      createdAt: createdAt,
    );
  }

  factory CarAdWithSeller.fromJson(Map<String, dynamic> json) {
    return CarAdWithSeller(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      color: json['color'] as String?,
      hp: json['hp'] as int,
      displacement: json['displacement'] as int,
      mileage: json['mileage'] as int,
      price: json['price'] as int,
      bodyType: json['bodyType'] as String?,
      condition: json['condition'] as String?,
      doorCount: json['doorCount'] as String?,
      cylinderCount: json['cylinderCount'] as String?,
      transmissionType: json['transmissionType'] as String?,
      fuelType: json['fuelType'] as String?,
      steeringPosition: json['steeringPosition'] as String?,
      driveType: json['driveType'] as String?,
      ownerCount: json['ownerCount'] as int,
      phone: json['phone'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      features: List<String>.from(json['features'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      seller: User.fromJson(json['seller'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'hp': hp,
      'displacement': displacement,
      'mileage': mileage,
      'price': price,
      'bodyType': bodyType,
      'condition': condition,
      'doorCount': doorCount,
      'cylinderCount': cylinderCount,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'steeringPosition': steeringPosition,
      'driveType': driveType,
      'ownerCount': ownerCount,
      'phone': phone,
      'region': region,
      'city': city,
      'imageUrls': imageUrls,
      'features': features,
      'createdAt': createdAt.toIso8601String(),
      'seller': seller.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        make,
        model,
        year,
        color,
        hp,
        displacement,
        mileage,
        price,
        bodyType,
        condition,
        doorCount,
        cylinderCount,
        transmissionType,
        fuelType,
        steeringPosition,
        driveType,
        ownerCount,
        phone,
        region,
        city,
        imageUrls,
        features,
        createdAt,
        seller,
      ];
}
