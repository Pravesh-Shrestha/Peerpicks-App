import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String pickId;
  final String authorId;
  final String authorName;
  final String? authorProfilePicture;
  final String content;
  final String? parentCommentId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommentEntity({
    required this.id,
    required this.pickId,
    required this.authorId,
    required this.authorName,
    this.authorProfilePicture,
    required this.content,
    this.parentCommentId,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, pickId, authorId, content, createdAt];
}
