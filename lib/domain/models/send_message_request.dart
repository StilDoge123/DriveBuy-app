import 'package:equatable/equatable.dart';

class SendMessageRequest extends Equatable {
  final String content;

  const SendMessageRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  @override
  List<Object?> get props => [content];
}
