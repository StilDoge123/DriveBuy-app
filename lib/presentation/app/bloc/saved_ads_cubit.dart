import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../presentation/app/di/locator.dart';

class SavedAdsCubit extends Cubit<Set<int>> {
  SavedAdsCubit() : super({});

  Future<void> fetchSavedAds(String userId) async {
    try {
      final userRepository = locator<UserRepository>();
      final savedAds = await userRepository.getSavedAds();
      emit(savedAds.map((ad) => ad.id).toSet());
    } catch (e) {
      print('Error fetching saved ads: $e');
      // Emit empty set on error to avoid breaking the UI
      emit({});
    }
  }

  void addSavedAd(int adId) => emit({...state, adId});
  void removeSavedAd(int adId) => emit({...state}..remove(adId));
  bool isAdSaved(int adId) => state.contains(adId);
}