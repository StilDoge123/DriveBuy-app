import 'package:equatable/equatable.dart';

class ChatUser extends Equatable {
  final String id;
  final String name;
  final String? phone;

  const ChatUser({
    required this.id,
    required this.name,
    this.phone,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    print('🔍 ChatUser.fromJson: Input data: $json');
    print('🔍 ChatUser.fromJson: Available keys: ${json.keys.toList()}');
    
    // Try different possible ID field names
    String? id;
    if (json.containsKey('id')) {
      id = json['id']?.toString();
    } else if (json.containsKey('uid')) {
      id = json['uid']?.toString();
    } else if (json.containsKey('userId')) {
      id = json['userId']?.toString();
    } else if (json.containsKey('firebaseId')) {
      id = json['firebaseId']?.toString();
    }
    
    print('🔍 ChatUser.fromJson: Extracted ID: $id');
    
    return ChatUser(
      id: id ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [id, name, phone];
}
