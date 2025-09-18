import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class EditAdEvent extends Equatable {
  const EditAdEvent();

  @override
  List<Object?> get props => [];
}

class EditAdLoad extends EditAdEvent {
  final int adId;

  const EditAdLoad(this.adId);

  @override
  List<Object?> get props => [adId];
}

class EditAdSubmit extends EditAdEvent {
  final int adId;
  final Map<String, dynamic> adData;
  final List<XFile> newImages;
  final List<String> imagesToDelete;

  const EditAdSubmit({
    required this.adId,
    required this.adData,
    required this.newImages,
    required this.imagesToDelete,
  });

  @override
  List<Object?> get props => [adId, adData, newImages, imagesToDelete];
}
