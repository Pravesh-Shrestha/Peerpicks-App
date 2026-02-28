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

class _UserProfileViewScreenState extends ConsumerState<UserProfileViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasSyncedFollow = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref
          .read(picksViewModelProvider.notifier)
          .getUserProfileWithPicks(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    final followerCount = lastCounts?['followerCount'] ?? profile?['followerCount'] ?? 0;
    final followingCount = lastCounts?['followingCount'] ?? profile?['followingCount'] ?? 0;
    final picksCount = picksState.picks.length;

    // Sync isFollowing from server once
    if (!_hasSyncedFollow && profile != null) {
      final serverIsFollowing = profile['isFollowing'] as bool? ?? false;
      _hasSyncedFollow = true;
      Future.microtask(() {
        ref.read(socialViewModelProvider.notifier).syncFollowFromProfile(
              widget.userId,
              serverIsFollowing,
            );
      });
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── App bar ──
          SliverAppBar(
            pinned: true,
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
            centerTitle: false,
          ),

          // ── Profile header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + stats
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 42,
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
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                ),
                              )
                            : null,
                      ),
                      const Spacer(),
                      _StatColumn(value: picksCount.toString(), label: 'Picks'),
                      const SizedBox(width: 24),
                      _StatColumn(
                        value: _formatCount(followerCount),
                        label: 'Followers',
                      ),
                      const SizedBox(width: 24),
                      _StatColumn(
                        value: _formatCount(followingCount),
                        label: 'Following',
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          label: 'Message',
                          filled: false,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          size: 18,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Tab bar ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: cs.onSurface,
                unselectedLabelColor: cs.onSurfaceVariant,
                indicatorColor: cs.onSurface,
                indicatorWeight: 1.5,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on, size: 22)),
                  Tab(icon: Icon(Icons.bookmark_border, size: 22)),
                ],
              ),
            ),
          ),
        ],

        // ── Tab views ──
        body: TabBarView(
          controller: _tabController,
          children: [
            // Grid tab
            _buildPicksGrid(picksState),
            // Saved tab (placeholder)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 48, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text(
                    'No saved picks',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicksGrid(PicksState picksState) {
    final cs = Theme.of(context).colorScheme;
    if (picksState.status == PicksStatus.loading) {
      return Center(
        child: CircularProgressIndicator(color: cs.primary),
      );
    }

    if (picksState.picks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 52, color: cs.outlineVariant),
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
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemCount: picksState.picks.length,
      itemBuilder: (context, index) {
        final pick = picksState.picks[index];
        return _GridPickTile(pick: pick);
      },
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
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
// Sticky TabBar Delegate
// ─────────────────────────────────────────────────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────
// Grid Pick Tile (Instagram-style square tile)
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: ApiEndpoints.resolveServerUrl(imageUrl),
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: cs.surfaceContainerHighest),
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
          // Multi-image badge
          if (pick.mediaUrls.length > 1)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(
                Icons.collections_rounded,
                color: Colors.white,
                size: 18,
                shadows: [Shadow(blurRadius: 4)],
              ),
            ),
          // Video badge
          if (hasVideo && imageUrl != null)
            const Positioned(
              top: 6,
              left: 6,
              child: Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 18,
                shadows: [Shadow(blurRadius: 4)],
              ),
            ),
        ],
      ),
    );
  }
}
