import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_client.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/core/services/connectivity/network_info.dart';
import 'package:peerpicks/features/map/presentation/state/nearby_state.dart';
import 'package:peerpicks/features/picks/data/models/pick_model.dart';

final nearbyViewModelProvider = NotifierProvider<NearbyViewModel, NearbyState>(
  NearbyViewModel.new,
);

class NearbyViewModel extends Notifier<NearbyState> {
  late final ApiClient _apiClient;
  late final INetworkInfo _networkInfo;

  @override
  NearbyState build() {
    _apiClient = ref.read(apiClientProvider);
    _networkInfo = ref.read(networkInfoProvider);
    return const NearbyState();
  }

  Future<void> getNearbyPicks({
    required double lat,
    required double lng,
    double radius = 5000,
  }) async {
    state = state.copyWith(
      status: NearbyStatus.loading,
      currentLat: lat,
      currentLng: lng,
    );

    if (!await _networkInfo.isConnected) {
      state = state.copyWith(
        status: NearbyStatus.error,
        errorMessage: 'No internet connection',
      );
      return;
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.nearbyPicks,
        queryParameters: {'lng': lng, 'lat': lat, 'radius': radius},
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] as List? ?? [];
        final picks = data
            .map((json) => PickModel.fromJson(json).toEntity())
            .toList();
        state = state.copyWith(status: NearbyStatus.loaded, nearbyPicks: picks);
      } else {
        state = state.copyWith(
          status: NearbyStatus.error,
          errorMessage: 'Failed to load nearby picks',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        status: NearbyStatus.error,
        errorMessage: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      state = state.copyWith(
        status: NearbyStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
