import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/presentation/view_model/picks_viewmodel.dart';
import 'package:peerpicks/features/social/presentation/state/social_state.dart';
import 'package:peerpicks/features/social/presentation/view_model/social_viewmodel.dart';
import 'package:peerpicks/features/social/domain/entities/comment_entity.dart';
import 'package:peerpicks/features/profile/presentation/pages/user_profile_view_screen.dart';
import 'package:peerpicks/widgets/video_player_widget.dart';

class PickDetailScreen extends ConsumerStatefulWidget {
  final String pickId;

  const PickDetailScreen({super.key, required this.pickId});

  @override
  ConsumerState<PickDetailScreen> createState() => _PickDetailScreenState();
}

class _PickDetailScreenState extends ConsumerState<PickDetailScreen> {
  final _commentController = TextEditingController();
  ProviderSubscription? _pickSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(picksViewModelProvider.notifier).getPickById(widget.pickId);
      ref
          .read(socialViewModelProvider.notifier)
          .getPickDiscussion(widget.pickId);

      // Sync voted state when the pick loads
      _pickSubscription = ref.listenManual(picksViewModelProvider, (
        prev,
        next,
      ) {
        if (next.selectedPick != null && next.selectedPick!.hasUpvoted) {
          ref.read(socialViewModelProvider.notifier).syncVotedFromPicks([
            next.selectedPick!,
          ]);
        }
      });
    });
  }

  @override
  void dispose() {
    _pickSubscription?.close();
    _commentController.dispose();
    super.dispose();
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

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  bool _hasValidLocation(PickEntity pick) {
    return pick.latitude != 0 && pick.longitude != 0;
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

  Future<void> _openInMap(PickEntity pick) async {
    final url = Uri.parse(
      'https://www.openstreetmap.org/?mlat=${pick.latitude}&mlon=${pick.longitude}#map=17/${pick.latitude}/${pick.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showShareSheet(PickEntity pick) {
    final text =
        'Check out "${pick.alias}" on PeerPicks! ${pick.description.length > 100 ? '${pick.description.substring(0, 100)}...' : pick.description}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sheetCs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetCs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Share this pick',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: sheetCs.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      icon: Icons.copy_rounded,
                      label: 'Copy Link',
                      color: sheetCs.primary,
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
                    _buildShareOption(
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
                    _buildShareOption(
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
                    _buildShareOption(
                      icon: Icons.open_in_browser_rounded,
                      label: 'More',
                      color: Colors.grey[700]!,
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
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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

  // --------------- build ---------------

  @override
  Widget build(BuildContext context) {
    final picksState = ref.watch(picksViewModelProvider);
    final socialState = ref.watch(socialViewModelProvider);
    final pick = picksState.selectedPick;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: pick == null
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(pick, isTablet),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User header
                        _buildUserHeader(pick, isTablet),
                        const SizedBox(height: 16),
                        // Title & Rating
                        _buildHeader(pick, isTablet),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          pick.description,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 15,
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Location + Map
                        if (_hasValidLocation(pick)) ...[
                          _buildLocationSection(pick, isTablet),
                          const SizedBox(height: 20),
                        ],
                        // Tags
                        if (pick.tags.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pick.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: cs.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Engagement Actions
                        _buildEngagementBar(pick, socialState, cs),
                        const Divider(height: 40),
                        // Comments Header
                        Text(
                          'Discussion (${socialState.comments.length})',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCommentInput(cs),
                        const SizedBox(height: 16),
                        _buildCommentsList(socialState, cs),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(PickEntity pick, bool isTablet) {
    final hasMedia = pick.mediaUrls.isNotEmpty;
    final appBarHeight = isTablet ? 360.0 : 300.0;

    return SliverAppBar(
      expandedHeight: hasMedia ? appBarHeight : 120,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white, size: 20),
          ),
          onPressed: () => _showShareSheet(pick),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasMedia
            ? _buildMediaViewer(pick, appBarHeight)
            : Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.place, color: Color(0xFFC5FF41), size: 60),
                ),
              ),
      ),
    );
  }

  Widget _buildMediaViewer(PickEntity pick, double height) {
    if (pick.mediaUrls.length == 1) {
      final url = pick.mediaUrls.first;
      if (_isVideo(url)) {
        return VideoPlayerWidget(videoUrl: url, height: height);
      }
      return SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: ApiEndpoints.resolveServerUrl(url),
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              placeholder: (_, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, url, error) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              ),
            ),
            // Fullscreen button
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
      );
    }

    return _DetailMediaSlider(urls: pick.mediaUrls, height: height);
  }

  Widget _buildUserHeader(PickEntity pick, bool isTablet) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _navigateToUserProfile(pick),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 22 : 18,
            backgroundColor: cs.outlineVariant,
            backgroundImage: pick.userProfilePicture != null
                ? CachedNetworkImageProvider(
                    ApiEndpoints.resolveServerUrl(pick.userProfilePicture!),
                  )
                : null,
            child: pick.userProfilePicture == null
                ? Text(
                    (pick.userName ?? 'U').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 16 : 14,
                      color: cs.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pick.userName ?? 'User',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 14,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  _timeAgo(pick.createdAt),
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (pick.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pick.category!,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(PickEntity pick, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            pick.alias,
            style: TextStyle(
              fontSize: isTablet ? 26 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB800).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 18,
                color: Color(0xFFFFB800),
              ),
              const SizedBox(width: 4),
              Text(
                pick.stars.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFFFB800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(PickEntity pick, bool isTablet) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.place_rounded, size: 20, color: cs.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                pick.locationName ?? 'Location',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _openInMap(pick),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 14,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Open Map',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Map widget
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: isTablet ? 220 : 180,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(pick.latitude, pick.longitude),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.peerpicks.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(pick.latitude, pick.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.place_rounded,
                        color: Color(0xFFD32F2F),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementBar(
    PickEntity pick,
    SocialState socialState,
    ColorScheme cs,
  ) {
    final isVoted = socialState.votedPickIds.contains(pick.id);
    final isFavorited = socialState.favoritedPickIds.contains(pick.id);

    return Row(
      children: [
        _EngagementButton(
          icon: isVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
          label: '${pick.upvoteCount}',
          isActive: isVoted,
          activeColor: cs.primary,
          onTap: () =>
              ref.read(socialViewModelProvider.notifier).toggleVote(pick.id),
        ),
        const SizedBox(width: 12),
        _EngagementButton(
          icon: Icons.chat_bubble_outline,
          label: '${socialState.comments.length}',
          isActive: false,
          activeColor: const Color(0xFF2196F3),
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _EngagementButton(
          icon: isFavorited ? Icons.bookmark : Icons.bookmark_border,
          label: 'Save',
          isActive: isFavorited,
          activeColor: const Color(0xFFFF9800),
          onTap: () => ref
              .read(socialViewModelProvider.notifier)
              .toggleFavorite(pick.id),
        ),
        const Spacer(),
        _EngagementButton(
          icon: Icons.share_outlined,
          label: 'Share',
          isActive: false,
          activeColor: Colors.grey,
          onTap: () => _showShareSheet(pick),
        ),
      ],
    );
  }

  Widget _buildCommentInput(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              hintStyle: TextStyle(color: cs.onSurfaceVariant),
              counterText: '',
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.send, color: cs.onPrimary, size: 20),
            onPressed: () async {
              final content = _commentController.text.trim();
              if (content.isEmpty) return;
              _commentController.clear();
              FocusScope.of(context).unfocus();
              await ref
                  .read(socialViewModelProvider.notifier)
                  .createComment(pickId: widget.pickId, content: content);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Comment posted!'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsList(SocialState socialState, ColorScheme cs) {
    if (socialState.status == SocialStatus.loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(color: cs.primary),
        ),
      );
    }

    if (socialState.comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.forum_outlined, size: 40, color: cs.outlineVariant),
              const SizedBox(height: 8),
              Text(
                'No comments yet. Start the conversation!',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final currentUserId = ref
        .read(userSessionServiceProvider)
        .getCurrentUserId();

    return Column(
      children: socialState.comments.map((comment) {
        final isOwner = comment.authorId == currentUserId;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (comment.authorId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileViewScreen(
                              userId: comment.authorId,
                              userName: comment.authorName,
                              userAvatar: comment.authorProfilePicture,
                            ),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.primary.withValues(alpha: 0.2),
                      backgroundImage: comment.authorProfilePicture != null
                          ? CachedNetworkImageProvider(
                              ApiEndpoints.resolveServerUrl(
                                comment.authorProfilePicture!,
                              ),
                            )
                          : null,
                      child: comment.authorProfilePicture == null
                          ? Text(
                              comment.authorName.isNotEmpty
                                  ? comment.authorName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (comment.authorId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfileViewScreen(
                                userId: comment.authorId,
                                userName: comment.authorName,
                                userAvatar: comment.authorProfilePicture,
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _timeAgo(comment.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCommentDialog(comment);
                        } else if (value == 'delete') {
                          _showDeleteCommentDialog(comment);
                        }
                      },
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 10),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
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
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                comment.content,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showEditCommentDialog(CommentEntity comment) {
    final editController = TextEditingController(text: comment.content);
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Comment'),
        content: TextField(
          controller: editController,
          maxLength: 1000,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Edit your comment...',
            counterText: '',
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newContent = editController.text.trim();
              if (newContent.isEmpty || newContent == comment.content) {
                Navigator.pop(ctx);
                return;
              }
              Navigator.pop(ctx);
              ref
                  .read(socialViewModelProvider.notifier)
                  .updateComment(commentId: comment.id, content: newContent);
              // Re-fetch to get updated list
              ref
                  .read(socialViewModelProvider.notifier)
                  .getPickDiscussion(widget.pickId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment updated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentDialog(CommentEntity comment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Comment'),
        content: const Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(socialViewModelProvider.notifier)
                  .deleteComment(comment.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment deleted'),
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
}

// ==================== ENGAGEMENT BUTTON ====================

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _EngagementButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.3)
                : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? activeColor : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DETAIL MEDIA SLIDER ====================

class _DetailMediaSlider extends StatefulWidget {
  final List<String> urls;
  final double height;

  const _DetailMediaSlider({required this.urls, required this.height});

  @override
  State<_DetailMediaSlider> createState() => _DetailMediaSliderState();
}

class _DetailMediaSliderState extends State<_DetailMediaSlider> {
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
              if (_PickDetailScreenState._isVideo(url)) {
                return VideoPlayerWidget(videoUrl: url, height: widget.height);
              }
              return Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: ApiEndpoints.resolveServerUrl(url),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: widget.height,
                    placeholder: (_, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
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
