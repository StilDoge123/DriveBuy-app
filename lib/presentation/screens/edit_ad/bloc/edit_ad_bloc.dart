import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/image_upload_service.dart';
import '../../../../data/services/cache_service.dart';
import '../../../../data/repositories/ad_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../presentation/app/di/locator.dart';
import 'edit_ad_event.dart';
import 'edit_ad_state.dart';

class EditAdBloc extends Bloc<EditAdEvent, EditAdState> {
  final ImageUploadService _imageUploadService;
  final AdRepository _adRepository;

  EditAdBloc({
    required ImageUploadService imageUploadService,
    required AdRepository adRepository,
  })  : _imageUploadService = imageUploadService,
        _adRepository = adRepository,
        super(const EditAdState()) {
    on<EditAdLoad>(_onLoad);
    on<EditAdSubmit>(_onSubmit);
  }

  Future<void> _onLoad(EditAdLoad event, Emitter<EditAdState> emit) async {
    emit(state.copyWith(status: EditAdStatus.loading));
    try {
      final ad = await _adRepository.getAd(event.adId);
      emit(state.copyWith(
        status: EditAdStatus.loaded,
        ad: ad,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditAdStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSubmit(EditAdSubmit event, Emitter<EditAdState> emit) async {
    emit(state.copyWith(status: EditAdStatus.submitting));
    try {
      // Get current user to include userId in the request
      final user = await _getUser();
      final adDataWithUserId = Map<String, dynamic>.from(event.adData);
      adDataWithUserId['userId'] = user['id'];

      // Convert XFile to File for new images and upload them
      List<String> newImagePaths = [];
      if (event.newImages.isNotEmpty) {
        final imageFiles = event.newImages.map((xFile) => File(xFile.path)).toList();
        newImagePaths = await _imageUploadService.uploadImages(imageFiles, adDataWithUserId);
      }

      // Update the ad
      final updatedAd = await _adRepository.updateAd(
        event.adId,
        adDataWithUserId,
        newImagePaths.isEmpty ? null : newImagePaths,
        event.imagesToDelete.isEmpty ? null : event.imagesToDelete,
      );

      // Invalidate relevant caches after successful update
      final cacheService = CacheService();
      cacheService.invalidateAdCaches(event.adId, user['id']);

      emit(state.copyWith(
        status: EditAdStatus.success,
        ad: updatedAd,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditAdStatus.failure,
        errorMessage: e.toString(),
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
