import 'package:equatable/equatable.dart';

class CarSearchFilter extends Equatable {
  final String? make;
  final String? model;
  final String? keywordSearch;
  final int? yearFrom;
  final int? yearTo;
  final int? minPrice;
  final int? maxPrice;
  final int? minHp;
  final int? maxHp;
  final int? minDisplacement;
  final int? maxDisplacement;
  final int? minMileage;
  final int? maxMileage;
  final int? minOwnerCount;
  final int? maxOwnerCount;
  final String? region;
  final String? city;
  final String? color;
  final List<String>? features;
  final List<String>? conditions;
  final String? transmissionType;
  final String? fuelType;
  final String? bodyType;
  final String? doorCount;
  final int? hp;
  final int? displacement;
  final int? ownerCount;
  final String? steeringPosition;
  final String? cylinderCount;
  final String? driveType;
  final int? hpFrom;
  final int? hpTo;
  final int? displacementFrom;
  final int? displacementTo;
  final int? mileageFrom;
  final int? mileageTo;
  final int? ownerCountFrom;
  final int? ownerCountTo;
  final String? sortBy;

  const CarSearchFilter({
    this.make,
    this.model,
    this.keywordSearch,
    this.yearFrom,
    this.yearTo,
    this.minPrice,
    this.maxPrice,
    this.minHp,
    this.maxHp,
    this.minDisplacement,
    this.maxDisplacement,
    this.minMileage,
    this.maxMileage,
    this.minOwnerCount,
    this.maxOwnerCount,
    this.region,
    this.city,
    this.color,
    this.features,
    this.conditions,
    this.transmissionType,
    this.fuelType,
    this.bodyType,
    this.doorCount,
    this.hp,
    this.displacement,
    this.ownerCount,
    this.steeringPosition,
    this.cylinderCount,
    this.driveType,
    this.hpFrom,
    this.hpTo,
    this.displacementFrom,
    this.displacementTo,
    this.mileageFrom,
    this.mileageTo,
    this.ownerCountFrom,
    this.ownerCountTo,
    this.sortBy,
  });

  factory CarSearchFilter.fromJson(Map<String, dynamic> json) {
    return CarSearchFilter(
      make: json['make'] as String?,
      model: json['model'] as String?,
      keywordSearch: json['keywordSearch'] as String?,
      yearFrom: json['yearFrom'] as int?,
      yearTo: json['yearTo'] as int?,
      minPrice: json['minPrice'] as int?,
      maxPrice: json['maxPrice'] as int?,
      color: json['color'] as String?,
      transmissionType: json['transmissionType'] as String?,
      fuelType: json['fuelType'] as String?,
      bodyType: json['bodyType'] as String?,
      doorCount: json['doorCount'] as String?,
      steeringPosition: json['steeringPosition'] as String?,
      cylinderCount: json['cylinderCount'] as String?,
      driveType: json['driveType'] as String?,
      hpFrom: json['hpFrom'] as int?,
      hpTo: json['hpTo'] as int?,
      displacementFrom: json['displacementFrom'] as int?,
      displacementTo: json['displacementTo'] as int?,
      mileageFrom: json['mileageFrom'] as int?,
      mileageTo: json['mileageTo'] as int?,
      ownerCountFrom: json['ownerCountFrom'] as int?,
      ownerCountTo: json['ownerCountTo'] as int?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      features: _parseStringOrList(json['features']),
      conditions: _parseStringOrList(json['conditions']),
      sortBy: json['sortBy'] as String?,
    );
  }

  static List<String>? _parseStringOrList(dynamic value) {
    if (value is String) {
      return value.split(',').map((s) => s.trim()).toList();
    } else if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  CarSearchFilter copyWith({
    Object? make = _freeze,
    Object? model = _freeze,
    Object? keywordSearch = _freeze,
    Object? yearFrom = _freeze,
    Object? yearTo = _freeze,
    Object? minPrice = _freeze,
    Object? maxPrice = _freeze,
    Object? minHp = _freeze,
    Object? maxHp = _freeze,
    Object? minDisplacement = _freeze,
    Object? maxDisplacement = _freeze,
    Object? minMileage = _freeze,
    Object? maxMileage = _freeze,
    Object? minDoorCount = _freeze,
    Object? maxDoorCount = _freeze,
    Object? minOwnerCount = _freeze,
    Object? maxOwnerCount = _freeze,
    Object? region = _freeze,
    Object? city = _freeze,
    Object? color = _freeze,
    Object? features = _freeze,
    Object? conditions = _freeze,
    Object? transmissionType = _freeze,
    Object? fuelType = _freeze,
    Object? bodyType = _freeze,
    Object? doorCount = _freeze,
    Object? hp = _freeze,
    Object? displacement = _freeze,
    Object? ownerCount = _freeze,
    Object? steeringPosition = _freeze,
    Object? cylinderCount = _freeze,
    Object? driveType = _freeze,
    Object? hpFrom = _freeze,
    Object? hpTo = _freeze,
    Object? displacementFrom = _freeze,
    Object? displacementTo = _freeze,
    Object? mileageFrom = _freeze,
    Object? mileageTo = _freeze,
    Object? ownerCountFrom = _freeze,
    Object? ownerCountTo = _freeze,
    Object? sortBy = _freeze,
  }) {
    return CarSearchFilter(
      make: make == _freeze ? this.make : make as String?,
      model: model == _freeze ? this.model : model as String?,
      keywordSearch: keywordSearch == _freeze ? this.keywordSearch : keywordSearch as String?,
      yearFrom: yearFrom == _freeze ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _freeze ? this.yearTo : yearTo as int?,
      minPrice: minPrice == _freeze ? this.minPrice : minPrice as int?,
      maxPrice: maxPrice == _freeze ? this.maxPrice : maxPrice as int?,
      minHp: minHp == _freeze ? this.minHp : minHp as int?,
      maxHp: maxHp == _freeze ? this.maxHp : maxHp as int?,
      minDisplacement: minDisplacement == _freeze ? this.minDisplacement : minDisplacement as int?,
      maxDisplacement: maxDisplacement == _freeze ? this.maxDisplacement : maxDisplacement as int?,
      minMileage: minMileage == _freeze ? this.minMileage : minMileage as int?,
      maxMileage: maxMileage == _freeze ? this.maxMileage : maxMileage as int?,
      minOwnerCount: minOwnerCount == _freeze ? this.minOwnerCount : minOwnerCount as int?,
      maxOwnerCount: maxOwnerCount == _freeze ? this.maxOwnerCount : maxOwnerCount as int?,
      region: region == _freeze ? this.region : region as String?,
      city: city == _freeze ? this.city : city as String?,
      color: color == _freeze ? this.color : color as String?,
      features: features == _freeze ? this.features : features as List<String>?,
      conditions: conditions == _freeze ? this.conditions : conditions as List<String>?,
      transmissionType: transmissionType == _freeze ? this.transmissionType : transmissionType as String?,
      fuelType: fuelType == _freeze ? this.fuelType : fuelType as String?,
      bodyType: bodyType == _freeze ? this.bodyType : bodyType as String?,
      doorCount: doorCount == _freeze ? this.doorCount : doorCount as String?,
      hp: hp == _freeze ? this.hp : hp as int?,
      displacement: displacement == _freeze ? this.displacement : displacement as int?,
      ownerCount: ownerCount == _freeze ? this.ownerCount : ownerCount as int?,
      steeringPosition: steeringPosition == _freeze ? this.steeringPosition : steeringPosition as String?,
      cylinderCount: cylinderCount == _freeze ? this.cylinderCount : cylinderCount as String?,
      driveType: driveType == _freeze ? this.driveType : driveType as String?,
      hpFrom: hpFrom == _freeze ? this.hpFrom : hpFrom as int?,
      hpTo: hpTo == _freeze ? this.hpTo : hpTo as int?,
      displacementFrom: displacementFrom == _freeze ? this.displacementFrom : displacementFrom as int?,
      displacementTo: displacementTo == _freeze ? this.displacementTo : displacementTo as int?,
      mileageFrom: mileageFrom == _freeze ? this.mileageFrom : mileageFrom as int?,
      mileageTo: mileageTo == _freeze ? this.mileageTo : mileageTo as int?,
      ownerCountFrom: ownerCountFrom == _freeze ? this.ownerCountFrom : ownerCountFrom as int?,
      ownerCountTo: ownerCountTo == _freeze ? this.ownerCountTo : ownerCountTo as int?,
      sortBy: sortBy == _freeze ? this.sortBy : sortBy as String?,
    );
  }

  static const Object _freeze = Object();

  @override
  List<Object?> get props => [
    make,
    model,
    keywordSearch,
    yearFrom,
    yearTo,
    minPrice,
    maxPrice,
    minHp,
    maxHp,
    minDisplacement,
    maxDisplacement,
    minMileage,
    maxMileage,
    minOwnerCount,
    maxOwnerCount,
    region,
    city,
    color,
    features,
    transmissionType,
    fuelType,
    bodyType,
    doorCount,
    hp,
    displacement,
    ownerCount,
    steeringPosition,
    cylinderCount,
    driveType,
    conditions,
    hpFrom,
    hpTo,
    displacementFrom,
    displacementTo,
    mileageFrom,
    mileageTo,
    ownerCountFrom,
    ownerCountTo,
    sortBy,
  ];

  bool get isEmpty =>
      make == null &&
      model == null &&
      keywordSearch == null &&
      yearFrom == null &&
      yearTo == null &&
      color == null &&
      minHp == null &&
      maxHp == null &&
      minDisplacement == null &&
      maxDisplacement == null &&
      minMileage == null &&
      maxMileage == null &&
      minPrice == null &&
      maxPrice == null &&
      minOwnerCount == null &&
      maxOwnerCount == null &&
      region == null &&
      city == null &&
      (features?.isEmpty ?? true) &&
      (conditions?.isEmpty ?? true) &&
      transmissionType == null &&
      fuelType == null && 
      bodyType == null &&
      doorCount == null && 
      hp == null && 
      displacement == null && 
      ownerCount == null &&
      steeringPosition == null &&
      cylinderCount == null &&
      driveType == null &&
      hpFrom == null &&
      hpTo == null &&
      displacementFrom == null &&
      displacementTo == null &&
      mileageFrom == null &&
      mileageTo == null &&
      ownerCountFrom == null &&
      ownerCountTo == null &&
      sortBy == null;

  /// Merges this filter with new preferences, with new preferences taking priority
  /// When a new make is specified, it clears the model to avoid conflicts
  CarSearchFilter mergeWithPreferences(CarSearchFilter newPrefs) {
    // Check if make is changing - if so, clear model to avoid conflicts
    String? resultModel = model;
    if (newPrefs.make != null && newPrefs.make != make) {
      resultModel = newPrefs.model; // Use new model if provided, otherwise clear
    } else if (newPrefs.model != null) {
      resultModel = newPrefs.model; // Update model if provided
    }

    return CarSearchFilter(
      make: newPrefs.make ?? make,
      model: resultModel,
      keywordSearch: newPrefs.keywordSearch ?? keywordSearch,
      yearFrom: newPrefs.yearFrom ?? yearFrom,
      yearTo: newPrefs.yearTo ?? yearTo,
      minPrice: newPrefs.minPrice ?? minPrice,
      maxPrice: newPrefs.maxPrice ?? maxPrice,
      minHp: newPrefs.minHp ?? minHp,
      maxHp: newPrefs.maxHp ?? maxHp,
      minDisplacement: newPrefs.minDisplacement ?? minDisplacement,
      maxDisplacement: newPrefs.maxDisplacement ?? maxDisplacement,
      minMileage: newPrefs.minMileage ?? minMileage,
      maxMileage: newPrefs.maxMileage ?? maxMileage,
      minOwnerCount: newPrefs.minOwnerCount ?? minOwnerCount,
      maxOwnerCount: newPrefs.maxOwnerCount ?? maxOwnerCount,
      region: newPrefs.region ?? region,
      city: newPrefs.city ?? city,
      color: newPrefs.color ?? color,
      features: newPrefs.features ?? features,
      conditions: newPrefs.conditions ?? conditions,
      transmissionType: newPrefs.transmissionType ?? transmissionType,
      fuelType: newPrefs.fuelType ?? fuelType,
      bodyType: newPrefs.bodyType ?? bodyType,
      doorCount: newPrefs.doorCount ?? doorCount,
      hp: newPrefs.hp ?? hp,
      displacement: newPrefs.displacement ?? displacement,
      ownerCount: newPrefs.ownerCount ?? ownerCount,
      steeringPosition: newPrefs.steeringPosition ?? steeringPosition,
      cylinderCount: newPrefs.cylinderCount ?? cylinderCount,
      driveType: newPrefs.driveType ?? driveType,
      hpFrom: newPrefs.hpFrom ?? hpFrom,
      hpTo: newPrefs.hpTo ?? hpTo,
      displacementFrom: newPrefs.displacementFrom ?? displacementFrom,
      displacementTo: newPrefs.displacementTo ?? displacementTo,
      mileageFrom: newPrefs.mileageFrom ?? mileageFrom,
      mileageTo: newPrefs.mileageTo ?? mileageTo,
      ownerCountFrom: newPrefs.ownerCountFrom ?? ownerCountFrom,
      ownerCountTo: newPrefs.ownerCountTo ?? ownerCountTo,
      sortBy: newPrefs.sortBy ?? sortBy,
    );
  }
} 