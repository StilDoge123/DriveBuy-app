import 'package:equatable/equatable.dart';

class CarFeature extends Equatable {
  final int id;
  final String name;

  const CarFeature({
    required this.id,
    required this.name,
  });

  factory CarFeature.fromJson(Map<String, dynamic> json) {
    return CarFeature(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
} 