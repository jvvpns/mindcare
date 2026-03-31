import 'package:hive/hive.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 6)
class ChatSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatSession copyWith({String? title, DateTime? updatedAt}) => ChatSession(
        id: id,
        title: title ?? this.title,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'ChatSession(id: $id, title: $title, createdAt: $createdAt)';
}
