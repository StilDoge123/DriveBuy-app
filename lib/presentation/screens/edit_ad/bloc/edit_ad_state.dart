import 'package:equatable/equatable.dart';
import '../../../../domain/models/car_ad.dart';

enum EditAdStatus { initial, loading, loaded, submitting, success, failure }

class EditAdState extends Equatable {
  final EditAdStatus status;
  final CarAd? ad;
  final String? errorMessage;

  const EditAdState({
    this.status = EditAdStatus.initial,
    this.ad,
    this.errorMessage,
  });

  EditAdState copyWith({
    EditAdStatus? status,
    CarAd? ad,
    String? errorMessage,
  }) {
    return EditAdState(
      status: status ?? this.status,
      ad: ad ?? this.ad,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, ad, errorMessage];
}
