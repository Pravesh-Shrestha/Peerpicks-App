import 'package:equatable/equatable.dart';
import 'package:peerpicks/features/blog/domain/entities/blog_entity.dart';

enum BlogStatus { initial, loading, loaded, error }

class BlogState extends Equatable {
  final BlogStatus status;
  final List<BlogEntity> blogs;
  final String? errorMessage;

  const BlogState({
    this.status = BlogStatus.initial,
    this.blogs = const [],
    this.errorMessage,
  });

  BlogState copyWith({
    BlogStatus? status,
    List<BlogEntity>? blogs,
    String? errorMessage,
  }) {
    return BlogState(
      status: status ?? this.status,
      blogs: blogs ?? this.blogs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, blogs, errorMessage];
}
