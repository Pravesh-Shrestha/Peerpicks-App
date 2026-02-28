import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/presentation/pages/pick_detail_screen.dart';
import 'package:peerpicks/features/picks/presentation/state/picks_state.dart';
import 'package:peerpicks/features/picks/presentation/view_model/picks_viewmodel.dart';
import 'package:peerpicks/features/social/presentation/view_model/social_viewmodel.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/search_screen.dart';
import 'package:peerpicks/features/profile/presentation/pages/user_profile_view_screen.dart';
import 'package:peerpicks/widgets/video_player_widget.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(picksViewModelProvider.notifier)
          .getDiscoveryFeed(page: 1, limit: 20);

      // Sync voted/favorited state when picks finish loading
      ref.listenManual(picksViewModelProvider, (prev, next) {
        if (next.status == PicksStatus.loaded && next.picks.isNotEmpty) {
          ref
              .read(socialViewModelProvider.notifier)
              .syncVotedFromPicks(next.picks);
        }
      });
    });
  }

  // --------------- helpers ---------------

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

  /// Reusable CachedNetworkImage — only call for images, never videos
  static Widget networkImage(
    String relativeUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    if (_isVideo(relativeUrl)) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.videocam_rounded, color: Colors.white54, size: 36),
        ),
      );
    }

    final resolvedUrl = ApiEndpoints.resolveServerUrl(relativeUrl);
    final image = CachedNetworkImage(
      imageUrl: resolvedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, url) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF75A638),
            ),
          ),
        ),
      ),
      errorWidget: (_, url, error) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 32),
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: image);
    }
    return image;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Future<void> _openInMap(PickEntity pick) async {
    final lat = pick.latitude;
    final lng = pick.longitude;
    final url = Uri.parse(
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToUserProfile(PickEntity pick) {
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

  void _showDeleteConfirmation(PickEntity pick) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Pick'),
        content: Text(
          'Are you sure you want to delete "${pick.alias}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(picksViewModelProvider.notifier).deletePick(pick.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pick deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(PickEntity pick) {
    final cs = Theme.of(context).colorScheme;
    final text =
        'Check out "${pick.alias}" on PeerPicks! ${pick.description.length > 100 ? '${pick.description.substring(0, 100)}...' : pick.description}';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Share this pick',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareOption(
                    icon: Icons.copy_rounded,
                    label: 'Copy Link',
                    color: cs.primary,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard!'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _ShareOption(
                    icon: Icons.message_rounded,
                    label: 'Message',
                    color: const Color(0xFF2196F3),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final smsUrl = Uri.parse(
                        'sms:?body=${Uri.encodeComponent(text)}',
                      );
                      if (await canLaunchUrl(smsUrl)) {
                        await launchUrl(smsUrl);
                      }
                    },
                  ),
                  _ShareOption(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    color: const Color(0xFFFF5722),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final emailUrl = Uri.parse(
                        'mailto:?subject=${Uri.encodeComponent('Check this out on PeerPicks!')}&body=${Uri.encodeComponent(text)}',
                      );
                      if (await canLaunchUrl(emailUrl)) {
                        await launchUrl(emailUrl);
                      }
                    },
                  ),
                  _ShareOption(
                    icon: Icons.open_in_browser_rounded,
                    label: 'More',
                    color: cs.onSurfaceVariant,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------- build ---------------

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final picksState = ref.watch(picksViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 64,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 24 : 20,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage: user?.profilePicture != null
                    ? CachedNetworkImageProvider(
                        ApiEndpoints.resolveServerUrl(user!.profilePicture!),
                      )
                    : null,
                child: user?.profilePicture == null
                    ? Icon(
                        Icons.person_rounded,
                        color: cs.onSurfaceVariant,
                        size: isTablet ? 26 : 22,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.fullName.split(' ')[0] ?? 'there'}',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    Text(
                      'Discover new places',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: isTablet ? 13 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                icon: Icon(Icons.search_rounded, color: cs.onSurface),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          bottom: TabBar(
            indicatorColor: cs.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: cs.onSurface,
            unselectedLabelColor: cs.onSurfaceVariant,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? 16 : 15,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Popular'),
              Tab(text: 'For You'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildPopularTab(picksState), _buildForYouTab(picksState)],
        ),
      ),
    );
  }

  // ==================== POPULAR TAB ====================

  Widget _buildPopularTab(PicksState picksState) {
    final isLoaded =
        picksState.status == PicksStatus.loaded && picksState.picks.isNotEmpty;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => ref
          .read(picksViewModelProvider.notifier)
          .getDiscoveryFeed(page: 1, limit: 20),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (isLoaded)
              _buildFeaturedCarousel(picksState.picks)
            else
              _buildCarouselSkeleton(),
            _sectionHeader('Trending'),
            isLoaded
                ? _buildHorizontalPicksList(picksState.picks)
                : _buildHorizontalSkeleton(),
            _sectionHeader('Top Rated'),
            isLoaded
                ? _buildHorizontalPicksList(
                    List.from(picksState.picks)
                      ..sort((a, b) => b.stars.compareTo(a.stars)),
                  )
                : _buildHorizontalSkeleton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<PickEntity> picks) {
    final featured = picks
        .where(
          (p) => p.mediaUrls.isNotEmpty && p.mediaUrls.any((u) => !_isVideo(u)),
        )
        .take(5)
        .toList();
    if (featured.isEmpty) return _buildCarouselSkeleton();

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return CarouselSlider.builder(
      itemCount: featured.length,
      options: CarouselOptions(
        height: isTablet ? 280 : 200,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        viewportFraction: isTablet ? 0.7 : 0.88,
      ),
      itemBuilder: (context, index, realIndex) {
        final pick = featured[index];
        final imgUrl = _firstImageUrl(pick);
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PickDetailScreen(pickId: pick.id),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imgUrl != null) networkImage(imgUrl),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 28, 14, 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pick.alias,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (pick.locationName != null) ...[
                                const Icon(
                                  Icons.place_outlined,
                                  color: Colors.white70,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    pick.locationName!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                pick.stars.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalPicksList(List<PickEntity> picks) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final cardWidth = isTablet ? 200.0 : 160.0;
    final cardHeight = isTablet ? 250.0 : 210.0;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: picks.length,
        itemBuilder: (context, index) {
          final pick = picks[index];
          final imgUrl = _firstImageUrl(pick);
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PickDetailScreen(pickId: pick.id),
              ),
            ),
            child: Container(
              width: cardWidth,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: isTablet ? 150 : 120,
                    width: double.infinity,
                    child: imgUrl != null
                        ? networkImage(
                            imgUrl,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    pick.mediaUrls.any((u) => _isVideo(u))
                                        ? Icons.videocam_rounded
                                        : Icons.place_rounded,
                                    color:
                                        pick.mediaUrls.any((u) => _isVideo(u))
                                        ? const Color(0xFFC5FF41)
                                        : Colors.grey[400],
                                    size: 36,
                                  ),
                                  if (pick.mediaUrls.any((u) => _isVideo(u)))
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Video',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pick.alias,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 14 : 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < pick.stars.round()
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: Colors.amber,
                                size: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              pick.stars.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${pick.upvoteCount}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${pick.commentCount}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
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
        },
      ),
    );
  }

  // ==================== FOR YOU TAB ====================

  Widget _buildForYouTab(PicksState picksState) {
    if (picksState.status == PicksStatus.loading ||
        picksState.status == PicksStatus.initial) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, idx) => _buildFeedSkeleton(),
      );
    }

    if (picksState.status == PicksStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              picksState.errorMessage ?? 'Something went wrong',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref
                  .read(picksViewModelProvider.notifier)
                  .getDiscoveryFeed(page: 1, limit: 20),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    final picks = picksState.picks;
    if (picks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 56, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              'No picks yet',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to share a place!',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => ref
          .read(picksViewModelProvider.notifier)
          .getDiscoveryFeed(page: 1, limit: 20),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 4),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: picks.length,
        itemBuilder: (context, index) => _buildFeedCard(picks[index]),
      ),
    );
  }

  Widget _buildFeedCard(PickEntity pick) {
    final socialState = ref.watch(socialViewModelProvider);
    final hasMedia = pick.mediaUrls.isNotEmpty;
    final isLiked = socialState.votedPickIds.contains(pick.id);
    final isSaved = socialState.favoritedPickIds.contains(pick.id);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final mediaHeight = isTablet ? 420.0 : 350.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 20 : 14,
              12,
              isTablet ? 20 : 14,
              8,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(pick),
                  child: CircleAvatar(
                    radius: isTablet ? 22 : 18,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage: pick.userProfilePicture != null
                        ? CachedNetworkImageProvider(
                            ApiEndpoints.resolveServerUrl(
                              pick.userProfilePicture!,
                            ),
                          )
                        : null,
                    child: pick.userProfilePicture == null
                        ? Text(
                            (pick.userName ?? pick.alias)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: isTablet ? 16 : 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToUserProfile(pick),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pick.userName ?? 'User',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 15 : 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _timeAgo(pick.createdAt),
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        pick.stars.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                // 3-dot menu for author actions (edit / delete)
                if (pick.userId ==
                    ref.read(userSessionServiceProvider).getCurrentUserId())
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(pick);
                      } else if (value == 'edit') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit feature coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    itemBuilder: (popupCtx) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Theme.of(popupCtx).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 10),
                            const Text('Edit Pick'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete Pick',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Place name + Location
          Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 20 : 14,
              0,
              isTablet ? 20 : 14,
              8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    pick.alias,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 17 : 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (pick.locationName != null ||
                    (pick.latitude != 0 && pick.longitude != 0))
                  GestureDetector(
                    onTap: () => _openInMap(pick),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 200 : 120,
                          ),
                          child: Text(
                            pick.locationName ?? 'View on map',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Media section
          if (hasMedia) _buildMediaSection(pick, mediaHeight),

          if (!hasMedia && pick.description.isNotEmpty)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PickDetailScreen(pickId: pick.id),
                ),
              ),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Text(
                  pick.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

          // Action bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 10,
              vertical: 8,
            ),
            child: Row(
              children: [
                _socialActionButton(
                  icon: isLiked
                      ? Icons.thumb_up_rounded
                      : Icons.thumb_up_alt_outlined,
                  label: '${pick.upvoteCount}',
                  isActive: isLiked,
                  onTap: () => ref
                      .read(socialViewModelProvider.notifier)
                      .toggleVote(pick.id),
                ),
                _socialActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${pick.commentCount}',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PickDetailScreen(pickId: pick.id),
                    ),
                  ),
                ),
                _socialActionButton(
                  icon: Icons.share_outlined,
                  label: '',
                  onTap: () => _showShareSheet(pick),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref
                      .read(socialViewModelProvider.notifier)
                      .toggleFavorite(pick.id),
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 22,
                    color: isSaved ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Description
          if (hasMedia && pick.description.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 20 : 14,
                0,
                isTablet ? 20 : 14,
                8,
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${pick.userName ?? pick.alias}  ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: pick.description,
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          if (pick.tags.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 20 : 14,
                0,
                isTablet ? 20 : 14,
                8,
              ),
              child: Wrap(
                spacing: 6,
                children: pick.tags
                    .take(4)
                    .map(
                      (tag) => Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          Container(height: 6, color: Colors.transparent),
        ],
      ),
      ),
    );
  }

  Widget _buildMediaSection(PickEntity pick, double mediaHeight) {
    final allMedia = pick.mediaUrls;

    if (allMedia.length == 1) {
      final url = allMedia.first;
      if (_isVideo(url)) {
        return VideoPlayerWidget(videoUrl: url, height: mediaHeight);
      }
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PickDetailScreen(pickId: pick.id)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: mediaHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              networkImage(url),
              // Fullscreen button overlay
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImageViewer(imageUrl: url),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _MediaSlider(
      urls: allMedia,
      height: mediaHeight,
      onImageTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PickDetailScreen(pickId: pick.id)),
      ),
    );
  }

  Widget _socialActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: isActive ? cs.primary : cs.onSurfaceVariant,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== Skeletons ====================

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCarouselSkeleton() {
    return CarouselSlider.builder(
      itemCount: 3,
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        viewportFraction: 0.88,
      ),
      itemBuilder: (_, idx, realIdx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalSkeleton() {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (_, idx) => Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, width: 100, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                    const SizedBox(height: 6),
                    Container(height: 8, width: 60, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, radius: 18),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, width: 100, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                    const SizedBox(height: 4),
                    Container(height: 8, width: 60, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 280,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(height: 12, width: 80, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                const SizedBox(width: 16),
                Container(height: 12, width: 60, color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SHARE OPTION ====================

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== MEDIA SLIDER ====================

class _MediaSlider extends StatefulWidget {
  final List<String> urls;
  final double height;
  final VoidCallback onImageTap;

  const _MediaSlider({
    required this.urls,
    required this.height,
    required this.onImageTap,
  });

  @override
  State<_MediaSlider> createState() => _MediaSliderState();
}

class _MediaSliderState extends State<_MediaSlider> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final url = widget.urls[index];
              if (_DashboardScreenState._isVideo(url)) {
                return VideoPlayerWidget(videoUrl: url, height: widget.height);
              }
              return GestureDetector(
                onTap: widget.onImageTap,
                child: SizedBox(
                  width: double.infinity,
                  height: widget.height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _DashboardScreenState.networkImage(url),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullscreenImageViewer(imageUrl: url),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.urls.length,
                (i) => Container(
                  width: i == _currentPage ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.urls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
