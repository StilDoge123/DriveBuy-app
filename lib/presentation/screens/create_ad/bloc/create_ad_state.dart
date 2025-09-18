import 'dart:io';
import 'package:equatable/equatable.dart';

enum CreateAdStatus { initial, uploading, success, failure }

class CreateAdState extends Equatable {
  final String make;
  final String model;
  final int year;
  final String color;
  final int hp;
  final int displacement;
  final int mileage;
  final int price;
  final String doorCount;
  final int ownerCount;
  final String phone;
  final String? region;
  final String? city;
  final List<File> selectedImages;
  final CreateAdStatus status;
  final String? errorMessage;
  final String title;
  final String description;
  final List<String> features;
  final String? transmissionType;
  final String? fuelType;
  final String? bodyType;
  final String? steeringPosition;
  final String? cylinderCount;
  final String? driveType;
  final String? condition;
  final String? userId;

  const CreateAdState({
    this.make = '',
    this.model = '',
    this.year = 2024,
    this.color = '',
    this.hp = 0,
    this.displacement = 0,
    this.mileage = 0,
    this.price = 0,
    this.doorCount = '',
    this.ownerCount = 0,
    this.phone = '',
    this.region = '',
    this.city = '',
    this.selectedImages = const [],
    this.status = CreateAdStatus.initial,
    this.errorMessage,
    this.title = '',
    this.description = '',
    this.features = const [],
    this.transmissionType,
    this.fuelType,
    this.bodyType,
    this.steeringPosition,
    this.cylinderCount,
    this.driveType,
    this.condition,
    this.userId,
  });

  CreateAdState copyWith({
    String? make,
    String? model,
    int? year,
    String? color,
    int? hp,
    int? displacement,
    int? mileage,
    int? price,
    String? doorCount,
    int? ownerCount,
    String? phone,
    String? region,
    String? city,
    List<File>? selectedImages,
    CreateAdStatus? status,
    String? errorMessage,
    String? title,
    String? description,
    List<String>? features,
    String? transmissionType,
    String? fuelType,
    String? bodyType,
    String? steeringPosition,
    String? cylinderCount,
    String? driveType,
    String? condition,
    String? userId,
  }) {
    return CreateAdState(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      hp: hp ?? this.hp,
      displacement: displacement ?? this.displacement,
      mileage: mileage ?? this.mileage,
      price: price ?? this.price,
      doorCount: doorCount ?? this.doorCount,
      ownerCount: ownerCount ?? this.ownerCount,
      phone: phone ?? this.phone,
      region: region ?? this.region,
      city: city ?? this.city,
      selectedImages: selectedImages ?? this.selectedImages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      title: title ?? this.title,
      description: description ?? this.description,
      features: features ?? this.features,
      transmissionType: transmissionType ?? this.transmissionType,
      fuelType: fuelType ?? this.fuelType,
      bodyType: bodyType ?? this.bodyType,
      steeringPosition: steeringPosition ?? this.steeringPosition,
      cylinderCount: cylinderCount ?? this.cylinderCount,
      driveType: driveType ?? this.driveType,
      condition: condition ?? this.condition,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'hp': hp,
      'displacement': displacement,
      'mileage': mileage,
      'price': price,
      'doorCount': doorCount,
      'ownerCount': ownerCount,
      'phone': phone,
      'region': region,
      'city': city,
      'title': title,
      'description': description,
      'features': features,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'bodyType': bodyType,
      'steeringPosition': steeringPosition,
      'cylinderCount': cylinderCount,
      'driveType': driveType,
      'condition': condition,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [
        make,
        model,
        year,
        color,
        hp,
        displacement,
        mileage,
        price,
        doorCount,
        ownerCount,
        phone,
        region,
        city,
        selectedImages,
        status,
        errorMessage,
        title,
        description,
        features,
        transmissionType,
        fuelType,
        bodyType,
        steeringPosition,
        cylinderCount,
        driveType,
        condition,
        userId,
      ];
} 