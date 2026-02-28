import 'package:peerpicks/features/blog/domain/entities/blog_entity.dart';

class BlogModel extends BlogEntity {
  const BlogModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    super.authorName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    // authorId can be a string or an object with _id
    String authorId;
    String? authorName;
    if (json['authorId'] is Map) {
      authorId = json['authorId']['_id'] ?? '';
      authorName = json['authorId']['name'] ?? json['authorId']['username'];
    } else {
      authorId = json['authorId']?.toString() ?? '';
    }

    return BlogModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: authorId,
      authorName: authorName,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content};
  }

  BlogEntity toEntity() => BlogEntity(
    id: id,
    title: title,
    content: content,
    authorId: authorId,
    authorName: authorName,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
