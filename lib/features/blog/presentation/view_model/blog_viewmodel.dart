import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/blog/data/repositories/blog_repository.dart';
import 'package:peerpicks/features/blog/domain/repositories/blog_repository.dart';
import 'package:peerpicks/features/blog/presentation/state/blog_state.dart';

class BlogViewModel extends Notifier<BlogState> {
  late final IBlogRepository _repository;

  @override
  BlogState build() {
    _repository = ref.read(blogRepositoryProvider);
    return const BlogState();
  }

  Future<void> getAllBlogs() async {
    state = state.copyWith(status: BlogStatus.loading);
    final result = await _repository.getAllBlogs();
    result.fold(
      (failure) => state = state.copyWith(
        status: BlogStatus.error,
        errorMessage: failure.message,
      ),
      (blogs) =>
          state = state.copyWith(status: BlogStatus.loaded, blogs: blogs),
    );
  }

  Future<bool> createBlog({
    required String title,
    required String content,
  }) async {
    final result = await _repository.createBlog(title: title, content: content);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (blog) {
        state = state.copyWith(blogs: [blog, ...state.blogs]);
        return true;
      },
    );
  }
}

final blogViewModelProvider = NotifierProvider<BlogViewModel, BlogState>(
  BlogViewModel.new,
);
