import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/presentation/pages/pick_detail_screen.dart';
import 'package:peerpicks/features/picks/presentation/view_model/picks_viewmodel.dart';
import 'package:peerpicks/features/picks/presentation/state/picks_state.dart';
import 'package:peerpicks/features/profile/presentation/pages/user_profile_view_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String? _selectedCategory;
  bool _hasSearched = false;

  static const _categories = [
    'All',
    'Restaurant',
    'Cafe',
    'Bar',
    'Hotel',
    'Shopping',
    'Entertainment',
    'Outdoor',
    'Other',
  ];

  // Randomized heights for Pinterest effect — cached per pick id
  final Map<String, double> _heightCache = {};

  @override
  void initState() {
    super.initState();
    // Load all picks for explore/discover view
    Future.microtask(() {
      ref
          .read(picksViewModelProvider.notifier)
          .getDiscoveryFeed(page: 1, limit: 50);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().isNotEmpty) {
        setState(() => _hasSearched = true);
        ref.read(picksViewModelProvider.notifier).searchPicks(query.trim());
      }
    });
  }

  void _onCategoryTap(String category) {
    setState(() {
      _selectedCategory = category == 'All' ? null : category;
    });
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

  List<PickEntity> _filterByCategory(List<PickEntity> picks) {
    if (_selectedCategory == null) return picks;
    return picks
        .where(
          (p) => p.category?.toLowerCase() == _selectedCategory!.toLowerCase(),
        )
        .toList();
  }

  double _getCardHeight(String pickId) {
    return _heightCache.putIfAbsent(pickId, () {
      final random = math.Random(pickId.hashCode);
      return 180 + random.nextDouble() * 120; // 180–300
    });
  }

  @override
  Widget build(BuildContext context) {
    final picksState = ref.watch(picksViewModelProvider);
    final filteredPicks = _filterByCategory(picksState.picks);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(cs),
        titleSpacing: 0,
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: cs.onSurfaceVariant, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() => _hasSearched = false);
                // Reload discovery feed
                ref
                    .read(picksViewModelProvider.notifier)
                    .getDiscoveryFeed(page: 1, limit: 50);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryChips(cs),
          Expanded(child: _buildBody(picksState, filteredPicks, isTablet, cs)),
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme cs) {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      onChanged: _onSearchChanged,
      style: TextStyle(fontSize: 15, color: cs.onSurface),
      decoration: InputDecoration(
        hintText: 'Search places, food, experiences...',
        hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildCategoryChips(ColorScheme cs) {
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _categories.map((cat) {
            final isSelected =
                (cat == 'All' && _selectedCategory == null) ||
                cat == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _onCategoryTap(cat),
                selectedColor: cs.primary.withValues(alpha: 0.3),
                backgroundColor: cs.surfaceContainerHighest,
                checkmarkColor: cs.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? cs.primary
                        : cs.outlineVariant,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody(
    PicksState picksState,
    List<PickEntity> picks,
    bool isTablet,
    ColorScheme cs,
  ) {
    if (!_hasSearched) {
      if (picksState.status == PicksStatus.loading && picks.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: cs.primary,
            strokeWidth: 2.5,
          ),
        );
      }
      if (picks.isEmpty) {
        return _buildEmptyState(
          cs: cs,
          icon: Icons.explore_rounded,
          title: 'Discover something new',
          subtitle: 'Search for places, restaurants, cafes and more',
        );
      }
      return _buildMasonryGrid(picks, isTablet, cs);
    }

    if (picksState.status == PicksStatus.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: cs.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (picksState.status == PicksStatus.error) {
      return _buildEmptyState(
        cs: cs,
        icon: Icons.error_outline,
        title: 'Something went wrong',
        subtitle: picksState.errorMessage ?? 'Please try again',
      );
    }

    if (picks.isEmpty) {
      return _buildEmptyState(
        cs: cs,
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: 'Try different keywords or categories',
      );
    }

    return _buildMasonryGrid(picks, isTablet, cs);
  }

  Widget _buildMasonryGrid(List<PickEntity> picks, bool isTablet, ColorScheme cs) {
    final columns = isTablet ? 3 : 2;
    final padding = isTablet ? 20.0 : 12.0;
    final spacing = isTablet ? 12.0 : 8.0;

    // Split picks into columns
    final List<List<PickEntity>> columnPicks = List.generate(
      columns,
      (_) => <PickEntity>[],
    );

    // Distribute picks to columns based on accumulated height
    final List<double> columnHeights = List.filled(columns, 0.0);
    for (final pick in picks) {
      // Find shortest column
      int shortestCol = 0;
      for (int i = 1; i < columns; i++) {
        if (columnHeights[i] < columnHeights[shortestCol]) {
          shortestCol = i;
        }
      }
      columnPicks[shortestCol].add(pick);
      columnHeights[shortestCol] += _getCardHeight(pick.id);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(columns, (colIndex) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: colIndex == 0 ? 0 : spacing / 2,
                right: colIndex == columns - 1 ? 0 : spacing / 2,
              ),
              child: Column(
                children: columnPicks[colIndex]
                    .map((pick) => _buildPinterestCard(pick, cs))
                    .toList(),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPinterestCard(PickEntity pick, ColorScheme cs) {
    final imgUrl = _firstImageUrl(pick);
    final hasVideo = pick.mediaUrls.any((u) => _isVideo(u));
    final cardImageHeight = _getCardHeight(pick.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PickDetailScreen(pickId: pick.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: SizedBox(
                height: cardImageHeight,
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
                              width: 18,
                              height: 18,
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
                              size: 28,
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
                            size: 32,
                          ),
                        ),
                      ),
                    // Video badge
                    if (hasVideo)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    // Category badge
                    if (pick.category != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pick.category!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pick.alias,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (pick.locationName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 11,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              pick.locationName!,
                              style: TextStyle(
                                fontSize: 10,
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        pick.stars.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (pick.userName != null)
                        GestureDetector(
                          onTap: () {
                            if (pick.userId.isNotEmpty) {
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
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 8,
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
                                          fontSize: 7,
                                          fontWeight: FontWeight.w700,
                                          color: cs.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 3),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 55),
                                child: Text(
                                  pick.userName!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: cs.onSurfaceVariant,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required ColorScheme cs,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
