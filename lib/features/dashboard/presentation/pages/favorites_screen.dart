import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/presentation/pages/pick_detail_screen.dart';
import 'package:peerpicks/features/social/presentation/state/social_state.dart';
import 'package:peerpicks/features/social/presentation/view_model/social_viewmodel.dart';
import 'package:peerpicks/features/profile/presentation/pages/user_profile_view_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(socialViewModelProvider.notifier).getMyFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final socialState = ref.watch(socialViewModelProvider);
    final isTablet = MediaQuery.of(context).size.width > 600;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Saved Picks',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 24 : 22,
          ),
        ),
      ),
      body: _buildBody(socialState, isTablet, cs),
    );
  }

  Widget _buildBody(SocialState socialState, bool isTablet, ColorScheme cs) {
    if (socialState.status == SocialStatus.loading ||
        socialState.status == SocialStatus.initial) {
      return Center(
        child: CircularProgressIndicator(color: cs.primary),
      );
    }

    if (socialState.status == SocialStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text(
              socialState.errorMessage ?? 'Failed to load favorites',
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(socialViewModelProvider.notifier).getMyFavorites(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: cs.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (socialState.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 56, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No saved picks yet',
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any pick\nto save it for later!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(socialViewModelProvider.notifier).getMyFavorites();
      },
      color: cs.primary,
      child: isTablet
          ? GridView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: socialState.favorites.length,
              itemBuilder: (context, index) => _FavoritePickCard(
                pick: socialState.favorites[index],
                isTablet: true,
                onUnsave: () => _unsave(socialState.favorites[index].id),
                onTap: () => _openDetail(socialState.favorites[index]),
                onUserTap: () => _openUserProfile(socialState.favorites[index]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: socialState.favorites.length,
              itemBuilder: (context, index) => _FavoritePickCard(
                pick: socialState.favorites[index],
                isTablet: false,
                onUnsave: () => _unsave(socialState.favorites[index].id),
                onTap: () => _openDetail(socialState.favorites[index]),
                onUserTap: () => _openUserProfile(socialState.favorites[index]),
              ),
            ),
    );
  }

  void _unsave(String pickId) {
    ref.read(socialViewModelProvider.notifier).toggleFavorite(pickId);
    Future.delayed(const Duration(milliseconds: 300), () {
      ref.read(socialViewModelProvider.notifier).getMyFavorites();
    });
  }

  void _openDetail(PickEntity pick) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PickDetailScreen(pickId: pick.id)),
    );
  }

  void _openUserProfile(PickEntity pick) {
    if (pick.userId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileViewScreen(
          userId: pick.userId,
          userName: pick.userName,
          userAvatar: pick.userProfilePicture,
        ),
      ),
    );
  }
}

class _FavoritePickCard extends StatelessWidget {
  final PickEntity pick;
  final bool isTablet;
  final VoidCallback onUnsave;
  final VoidCallback onTap;
  final VoidCallback onUserTap;

  const _FavoritePickCard({
    required this.pick,
    required this.isTablet,
    required this.onUnsave,
    required this.onTap,
    required this.onUserTap,
  });

  static bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mpeg') ||
        lower.endsWith('.avi');
  }

  static String? _firstImageUrl(PickEntity pick) {
    for (final url in pick.mediaUrls) {
      if (!_isVideo(url)) return url;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = _firstImageUrl(pick);
    final hasVideo = pick.mediaUrls.any((u) => _isVideo(u));
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: isTablet ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media preview
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: isTablet ? 140 : 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imgUrl != null)
                      CachedNetworkImage(
                        imageUrl: ApiEndpoints.resolveServerUrl(imgUrl),
                        fit: BoxFit.cover,
                        placeholder: (_, url) => Container(
                          color: cs.surfaceContainerHighest,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, url, error) => Container(
                          color: cs.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: cs.onSurfaceVariant,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: cs.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            hasVideo
                                ? Icons.videocam_rounded
                                : Icons.place_rounded,
                            color: cs.outlineVariant,
                            size: 40,
                          ),
                        ),
                      ),
                    // Rating badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              pick.stars.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Video indicator
                    if (hasVideo)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.videocam_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    // Unsave button
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: onUnsave,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.bookmark_rounded,
                            color: cs.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    pick.alias,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 15 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  if (pick.locationName != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            pick.locationName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Description
                  if (!isTablet)
                    Text(
                      pick.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 8),

                  // User + Engagement
                  Row(
                    children: [
                      if (pick.userName != null)
                        GestureDetector(
                          onTap: onUserTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: cs.outlineVariant,
                                backgroundImage: pick.userProfilePicture != null
                                    ? CachedNetworkImageProvider(
                                        ApiEndpoints.resolveServerUrl(
                                          pick.userProfilePicture!,
                                        ),
                                      )
                                    : null,
                                child: pick.userProfilePicture == null
                                    ? Text(
                                        pick.userName!
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: cs.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pick.userName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${pick.upvoteCount}',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${pick.commentCount}',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
