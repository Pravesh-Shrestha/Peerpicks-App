import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/blog/domain/entities/blog_entity.dart';
import 'package:peerpicks/features/blog/presentation/pages/create_blog_screen.dart';
import 'package:peerpicks/features/blog/presentation/state/blog_state.dart';
import 'package:peerpicks/features/blog/presentation/view_model/blog_viewmodel.dart';

class BlogListScreen extends ConsumerStatefulWidget {
  const BlogListScreen({super.key});

  @override
  ConsumerState<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends ConsumerState<BlogListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(blogViewModelProvider.notifier).getAllBlogs(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blogViewModelProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Blog',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const CreateBlogScreen()),
              );
              if (created == true) {
                ref.read(blogViewModelProvider.notifier).getAllBlogs();
              }
            },
            icon: Icon(Icons.add, color: cs.primary),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(BlogState state) {
    final cs = Theme.of(context).colorScheme;
    if (state.status == BlogStatus.loading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }
    if (state.status == BlogStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Something went wrong',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  ref.read(blogViewModelProvider.notifier).getAllBlogs(),
              child: Text('Retry', style: TextStyle(color: cs.primary)),
            ),
          ],
        ),
      );
    }
    if (state.blogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 56, color: cs.outlineVariant),
            const SizedBox(height: 12),
            Text(
              'No blog posts yet',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () => ref.read(blogViewModelProvider.notifier).getAllBlogs(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.blogs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final blog = state.blogs[index];
          return _BlogCard(blog: blog);
        },
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final BlogEntity blog;
  const _BlogCard({required this.blog});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _BlogDetailScreen(blog: blog)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                blog.content,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (blog.authorName != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      blog.authorName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                  ],
                  Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(blog.createdAt),
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

class _BlogDetailScreen extends StatelessWidget {
  final BlogEntity blog;
  const _BlogDetailScreen({required this.blog});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (blog.authorName != null) ...[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: cs.primary,
                    child: Text(
                      blog.authorName![0].toUpperCase(),
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    blog.authorName!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  _formatDate(blog.createdAt),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              blog.content,
              style: TextStyle(fontSize: 16, height: 1.8, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}
