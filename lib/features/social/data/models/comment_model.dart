import 'package:peerpicks/features/social/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.pickId,
    required super.authorId,
    required super.authorName,
    super.authorProfilePicture,
    required super.content,
    super.parentCommentId,
    super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'];
    String authorId = '';
    String authorName = 'Unknown';
    String? authorPic;

    if (author is Map<String, dynamic>) {
      authorId = author['_id'] ?? '';
      authorName = author['fullName'] ?? 'Unknown';
      authorPic = author['profilePicture'];
    } else if (author is String) {
      authorId = author;
    }

    return CommentModel(
      id: json['_id'] ?? '',
      pickId: json['pick'] is Map ? json['pick']['_id'] : json['pick'] ?? '',
      authorId: authorId,
      authorName: authorName,
      authorProfilePicture: authorPic,
      content: json['content'] ?? '',
      parentCommentId: json['parentComment'],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pick': pickId,
      'content': content,
      if (parentCommentId != null) 'parentComment': parentCommentId,
    };
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      pickId: pickId,
      authorId: authorId,
      authorName: authorName,
      authorProfilePicture: authorProfilePicture,
      content: content,
      parentCommentId: parentCommentId,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<CommentEntity> toEntityList(List<CommentModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
