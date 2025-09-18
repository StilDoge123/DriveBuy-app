import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class CreateAdEvent extends Equatable {
  const CreateAdEvent();

  @override
  List<Object?> get props => [];
}

class CreateAdMakeChanged extends CreateAdEvent {
  final String make;

  const CreateAdMakeChanged(this.make);

  @override
  List<Object?> get props => [make];
}

class CreateAdModelChanged extends CreateAdEvent {
  final String model;

  const CreateAdModelChanged(this.model);

  @override
  List<Object?> get props => [model];
}

class CreateAdYearChanged extends CreateAdEvent {
  final int year;

  const CreateAdYearChanged(this.year);

  @override
  List<Object?> get props => [year];
}

class CreateAdColorChanged extends CreateAdEvent {
  final String color;

  const CreateAdColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

class CreateAdHpChanged extends CreateAdEvent {
  final int hp;

  const CreateAdHpChanged(this.hp);

  @override
  List<Object?> get props => [hp];
}

class CreateAdDisplacementChanged extends CreateAdEvent {
  final int displacement;

  const CreateAdDisplacementChanged(this.displacement);

  @override
  List<Object?> get props => [displacement];
}

class CreateAdMileageChanged extends CreateAdEvent {
  final int mileage;

  const CreateAdMileageChanged(this.mileage);

  @override
  List<Object?> get props => [mileage];
}

class CreateAdPriceChanged extends CreateAdEvent {
  final int price;

  const CreateAdPriceChanged(this.price);

  @override
  List<Object?> get props => [price];
}

class CreateAdDoorCountChanged extends CreateAdEvent {
  final String doorCount;

  const CreateAdDoorCountChanged(this.doorCount);

  @override
  List<Object?> get props => [doorCount];
}

class CreateAdOwnerCountChanged extends CreateAdEvent {
  final int ownerCount;

  const CreateAdOwnerCountChanged(this.ownerCount);

  @override
  List<Object?> get props => [ownerCount];
}

class CreateAdPhoneChanged extends CreateAdEvent {
  final String phone;

  const CreateAdPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class CreateAdRegionChanged extends CreateAdEvent {
  final String region;

  const CreateAdRegionChanged(this.region);

  @override
  List<Object?> get props => [region];
}

class CreateAdCityChanged extends CreateAdEvent {
  final String city;

  const CreateAdCityChanged(this.city);

  @override
  List<Object?> get props => [city];
}

class CreateAdImagesAdded extends CreateAdEvent {
  final List<File> images;

  const CreateAdImagesAdded(this.images);

  @override
  List<Object?> get props => [images];
}

class CreateAdImageRemoved extends CreateAdEvent {
  final File image;

  const CreateAdImageRemoved(this.image);

  @override
  List<Object?> get props => [image];
}

class CreateAdSubmitted extends CreateAdEvent {
  const CreateAdSubmitted();
}

class CreateAdTitleChanged extends CreateAdEvent {
  final String title;
  const CreateAdTitleChanged(this.title);
  @override
  List<Object?> get props => [title];
}

class CreateAdDescriptionChanged extends CreateAdEvent {
  final String description;
  const CreateAdDescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

class CreateAdFeaturesChanged extends CreateAdEvent {
  final List<String> features;
  const CreateAdFeaturesChanged(this.features);
  @override
  List<Object?> get props => [features];
}

class CreateAdTransmissionTypeChanged extends CreateAdEvent {
  final String transmissionType;
  const CreateAdTransmissionTypeChanged(this.transmissionType);
  @override
  List<Object?> get props => [transmissionType];
}

class CreateAdFuelTypeChanged extends CreateAdEvent {
  final String fuelType;
  const CreateAdFuelTypeChanged(this.fuelType);
  @override
  List<Object?> get props => [fuelType];
}

class CreateAdBodyTypeChanged extends CreateAdEvent {
  final String bodyType;
  const CreateAdBodyTypeChanged(this.bodyType);
  @override
  List<Object?> get props => [bodyType];
}

class CreateAdSteeringPositionChanged extends CreateAdEvent {
  final String steeringPosition;
  const CreateAdSteeringPositionChanged(this.steeringPosition);
  @override
  List<Object?> get props => [steeringPosition];
}

class CreateAdCylinderCountChanged extends CreateAdEvent {
  final String cylinderCount;
  const CreateAdCylinderCountChanged(this.cylinderCount);
  @override
  List<Object?> get props => [cylinderCount];
}

class CreateAdDriveTypeChanged extends CreateAdEvent {
  final String driveType;
  const CreateAdDriveTypeChanged(this.driveType);
  @override
  List<Object?> get props => [driveType];
}

class CreateAdConditionChanged extends CreateAdEvent {
  final String condition;
  const CreateAdConditionChanged(this.condition);
  @override
  List<Object?> get props => [condition];
} 