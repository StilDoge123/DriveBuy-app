import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/image_upload_service.dart';
import 'create_ad_event.dart';
import 'create_ad_state.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../app/di/locator.dart';

class CreateAdBloc extends Bloc<CreateAdEvent, CreateAdState> {
  final ImageUploadService _imageUploadService;

  CreateAdBloc({required ImageUploadService imageUploadService})
      : _imageUploadService = imageUploadService,
        super(const CreateAdState()) {
    on<CreateAdMakeChanged>(_onMakeChanged);
    on<CreateAdModelChanged>(_onModelChanged);
    on<CreateAdYearChanged>(_onYearChanged);
    on<CreateAdColorChanged>(_onColorChanged);
    on<CreateAdHpChanged>(_onHpChanged);
    on<CreateAdDisplacementChanged>(_onDisplacementChanged);
    on<CreateAdMileageChanged>(_onMileageChanged);
    on<CreateAdPriceChanged>(_onPriceChanged);
    on<CreateAdDoorCountChanged>(_onDoorCountChanged);
    on<CreateAdOwnerCountChanged>(_onOwnerCountChanged);
    on<CreateAdPhoneChanged>(_onPhoneChanged);
    on<CreateAdRegionChanged>(_onRegionChanged);
    on<CreateAdCityChanged>(_onCityChanged);
    on<CreateAdImagesAdded>(_onImagesAdded);
    on<CreateAdImageRemoved>(_onImageRemoved);
    on<CreateAdSubmitted>(_onSubmitted);
    on<CreateAdTitleChanged>(_onTitleChanged);
    on<CreateAdDescriptionChanged>(_onDescriptionChanged);
    on<CreateAdFeaturesChanged>(_onFeaturesChanged);
    on<CreateAdTransmissionTypeChanged>(_onTransmissionTypeChanged);
    on<CreateAdFuelTypeChanged>(_onFuelTypeChanged);
    on<CreateAdBodyTypeChanged>(_onBodyTypeChanged);
    on<CreateAdSteeringPositionChanged>(_onSteeringPositionChanged);
    on<CreateAdCylinderCountChanged>(_onCylinderCountChanged);
    on<CreateAdDriveTypeChanged>(_onDriveTypeChanged);
    on<CreateAdConditionChanged>(_onConditionChanged);
  }

  void _onMakeChanged(CreateAdMakeChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(make: event.make, model: ''));
  }

  void _onModelChanged(CreateAdModelChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(model: event.model));
  }

  void _onYearChanged(CreateAdYearChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(year: event.year));
  }

  void _onColorChanged(CreateAdColorChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(color: event.color));
  }

  void _onHpChanged(CreateAdHpChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(hp: event.hp));
  }

  void _onDisplacementChanged(CreateAdDisplacementChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(displacement: event.displacement));
  }

  void _onMileageChanged(CreateAdMileageChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(mileage: event.mileage));
  }

  void _onPriceChanged(CreateAdPriceChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(price: event.price));
  }

  void _onDoorCountChanged(CreateAdDoorCountChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(doorCount: event.doorCount));
  }

  void _onOwnerCountChanged(CreateAdOwnerCountChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(ownerCount: event.ownerCount));
  }

  void _onPhoneChanged(CreateAdPhoneChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(phone: event.phone));
  }

  void _onRegionChanged(CreateAdRegionChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(region: event.region, city: ''));
  }

  void _onCityChanged(CreateAdCityChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(city: event.city));
  }

  void _onImagesAdded(CreateAdImagesAdded event, Emitter<CreateAdState> emit) {
    final updatedImages = List<File>.from(state.selectedImages)..addAll(event.images);
    emit(state.copyWith(selectedImages: updatedImages));
  }

  void _onImageRemoved(CreateAdImageRemoved event, Emitter<CreateAdState> emit) {
    final updatedImages = List<File>.from(state.selectedImages)..remove(event.image);
    emit(state.copyWith(selectedImages: updatedImages));
  }

  void _onTitleChanged(CreateAdTitleChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(CreateAdDescriptionChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onFeaturesChanged(CreateAdFeaturesChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(features: event.features));
  }

  void _onTransmissionTypeChanged(CreateAdTransmissionTypeChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(transmissionType: event.transmissionType));
  }

  void _onFuelTypeChanged(CreateAdFuelTypeChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(fuelType: event.fuelType));
  }

  void _onBodyTypeChanged(CreateAdBodyTypeChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(bodyType: event.bodyType));
  }

  void _onSteeringPositionChanged(CreateAdSteeringPositionChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(steeringPosition: event.steeringPosition));
  }

  void _onCylinderCountChanged(CreateAdCylinderCountChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(cylinderCount: event.cylinderCount));
  }

  void _onDriveTypeChanged(CreateAdDriveTypeChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(driveType: event.driveType));
  }

  void _onConditionChanged(CreateAdConditionChanged event, Emitter<CreateAdState> emit) {
    emit(state.copyWith(condition: event.condition));
  }

  Future<void> _onSubmitted(CreateAdSubmitted event, Emitter<CreateAdState> emit) async {
    if (state.selectedImages.isEmpty) {
      emit(state.copyWith(
        status: CreateAdStatus.failure,
        errorMessage: 'Please add at least one image',
      ));
      return;
    }

    emit(state.copyWith(status: CreateAdStatus.uploading));

    try {
      final user = await _getUser();
      final adData = state
          .copyWith(
            phone: user['phone'],
            userId: user['id'],
          )
          .toJson();
      final imageUrls = await _imageUploadService.uploadImages(
        state.selectedImages,
        adData,
      );
      emit(state.copyWith(status: CreateAdStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: CreateAdStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<Map<String, dynamic>> _getUser() async {
    final userRepository = locator<UserRepository>();
    try {
      final user = await userRepository.getCurrentUser();
      return user;
    } catch (e) {
      rethrow;
    }
  }
} 