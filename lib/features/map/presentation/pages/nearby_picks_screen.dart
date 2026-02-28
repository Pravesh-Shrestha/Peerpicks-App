import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/map/presentation/state/nearby_state.dart';
import 'package:peerpicks/features/map/presentation/view_model/nearby_viewmodel.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/presentation/pages/pick_detail_screen.dart';

class NearbyPicksScreen extends ConsumerStatefulWidget {
  const NearbyPicksScreen({super.key});

  @override
  ConsumerState<NearbyPicksScreen> createState() => _NearbyPicksScreenState();
}

class _NearbyPicksScreenState extends ConsumerState<NearbyPicksScreen> {
  @override
  void initState() {
    super.initState();
    // Default to Kathmandu coordinates — replace with actual geolocation
    Future.microtask(() {
      ref
          .read(nearbyViewModelProvider.notifier)
          .getNearbyPicks(lat: 27.7172, lng: 85.3240, radius: 10000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nearbyState = ref.watch(nearbyViewModelProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Nearby Picks',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: cs.onSurface),
            onPressed: () {
              ref
                  .read(nearbyViewModelProvider.notifier)
                  .getNearbyPicks(
                    lat: nearbyState.currentLat ?? 27.7172,
                    lng: nearbyState.currentLng ?? 85.3240,
                  );
            },
          ),
        ],
      ),
      body: _buildBody(nearbyState),
    );
  }

  Widget _buildBody(NearbyState nearbyState) {
    if (nearbyState.status == NearbyStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nearbyState.status == NearbyStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              nearbyState.errorMessage ?? 'Failed to load nearby picks',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (nearbyState.nearbyPicks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No picks nearby',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to review a place around here!',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: nearbyState.nearbyPicks.length,
      itemBuilder: (context, index) {
        return _NearbyPickCard(pick: nearbyState.nearbyPicks[index]);
      },
    );
  }
}

class _NearbyPickCard extends StatelessWidget {
  final PickEntity pick;

  const _NearbyPickCard({required this.pick});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PickDetailScreen(pickId: pick.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 80,
                height: 80,
                child: pick.mediaUrls.isNotEmpty
                    ? Image.network(
                        ApiEndpoints.resolveServerUrl(pick.mediaUrls.first),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.place,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pick.alias,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pick.description,
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pick.stars.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pick.upvoteCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: cs.onSurfaceVariant,
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
