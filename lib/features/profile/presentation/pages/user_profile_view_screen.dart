import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/presentation/pages/pick_detail_screen.dart';
import 'package:peerpicks/features/picks/presentation/state/picks_state.dart';
import 'package:peerpicks/features/picks/presentation/view_model/picks_viewmodel.dart';
import 'package:peerpicks/features/social/presentation/view_model/social_viewmodel.dart';

class UserProfileViewScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? userName;
  final String? userAvatar;

  const UserProfileViewScreen({
    super.key,
    required this.userId,
    this.userName,
    this.userAvatar,
  });

  @override
  ConsumerState<UserProfileViewScreen> createState() =>
      _UserProfileViewScreenState();
}

class _UserProfileViewScreenState extends ConsumerState<UserProfileViewScreen> {
  bool _hasSyncedFollow = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(picksViewModelProvider.notifier)
          .getUserProfileWithPicks(widget.userId);
    });
  }

  String _formatCount(dynamic count) {
    final n = count is int ? count : 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final picksState = ref.watch(picksViewModelProvider);
    final socialState = ref.watch(socialViewModelProvider);
    final isFollowing = socialState.followedUserIds.contains(widget.userId);
    final profile = picksState.viewedUserProfile;

    // Use server data if available, fallback to passed-in values
    final displayName = profile?['fullName'] ?? widget.userName ?? 'User';
    final displayAvatar = profile?['profilePicture'] ?? widget.userAvatar;
    // Use live counts from last toggle if available, else server profile
    final lastCounts = socialState.lastFollowCounts;
    final followerCount =
        lastCounts?['followerCount'] ?? profile?['followerCount'] ?? 0;
    final followingCount =
        lastCounts?['followingCount'] ?? profile?['followingCount'] ?? 0;
    final picksCount = picksState.picks.length;

    // Sync isFollowing from server once
    if (!_hasSyncedFollow && profile != null) {
      final serverIsFollowing = profile['isFollowing'] as bool? ?? false;
      _hasSyncedFollow = true;
      Future.microtask(() {
        ref
            .read(socialViewModelProvider.notifier)
            .syncFollowFromProfile(widget.userId, serverIsFollowing);
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: cs.outlineVariant,
                          backgroundImage: displayAvatar != null
                              ? CachedNetworkImageProvider(
                                  ApiEndpoints.resolveServerUrl(displayAvatar),
                                )
                              : null,
                          child: displayAvatar == null
                              ? Text(
                                  displayName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'PeerPicks Explorer',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatColumn(
                          value: picksCount.toString(),
                          label: 'Picks',
                        ),
                      ),
                      Expanded(
                        child: _StatColumn(
                          value: _formatCount(followerCount),
                          label: 'Followers',
                        ),
                      ),
                      Expanded(
                        child: _StatColumn(
                          value: _formatCount(followingCount),
                          label: 'Following',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: isFollowing ? 'Following' : 'Follow',
                          filled: !isFollowing,
                          onTap: () => ref
                              .read(socialViewModelProvider.notifier)
                              .toggleFollow(widget.userId),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PeerPicks Board',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _buildPicksGrid(picksState),
        ],
      ),
    );
  }

  Widget _buildPicksGrid(PicksState picksState) {
    final cs = Theme.of(context).colorScheme;
    if (picksState.status == PicksStatus.loading) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    if (picksState.picks.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 52,
                color: cs.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No picks yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'When this user shares picks, they will appear here.',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final pick = picksState.picks[index];
          return _GridPickTile(pick: pick);
        }, childCount: picksState.picks.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.92,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat Column (posts / followers / following)
// ─────────────────────────────────────────────────────────────
class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Action Button (Follow / Message)
// ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? cs.onSurface : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Grid Pick Tile
// ─────────────────────────────────────────────────────────────
class _GridPickTile extends StatelessWidget {
  final PickEntity pick;

  const _GridPickTile({required this.pick});

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
    final imageUrl = _firstImageUrl(pick);
    final hasVideo = pick.mediaUrls.any((u) => _isVideo(u));
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PickDetailScreen(pickId: pick.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: ApiEndpoints.resolveServerUrl(imageUrl),
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: cs.surfaceContainerHighest),
                errorWidget: (_, __, ___) => Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.broken_image, color: cs.onSurfaceVariant),
                ),
              )
            else
              Container(
                color: cs.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    hasVideo ? Icons.videocam_rounded : Icons.place_rounded,
                    color: cs.outlineVariant,
                    size: 28,
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pick.alias,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.thumb_up_alt_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${pick.upvoteCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (pick.mediaUrls.length > 1)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.collections_rounded,
                  color: Colors.white,
                  size: 18,
                  shadows: [Shadow(blurRadius: 4)],
                ),
              ),
            if (hasVideo && imageUrl != null)
              const Positioned(
                top: 8,
                left: 8,
                child: Icon(
                  Icons.videocam_rounded,
                  color: Colors.white,
                  size: 18,
                  shadows: [Shadow(blurRadius: 4)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
