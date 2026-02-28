import 'package:equatable/equatable.dart';

class BlogEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String? authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BlogEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    authorId,
    authorName,
    createdAt,
    updatedAt,
  ];
}
