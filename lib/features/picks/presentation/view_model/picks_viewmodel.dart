import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/picks/domain/usecases/create_pick_usecase.dart';
import 'package:peerpicks/features/picks/domain/usecases/delete_pick_usecase.dart';
import 'package:peerpicks/features/picks/domain/usecases/get_discovery_feed_usecase.dart';
import 'package:peerpicks/features/picks/domain/usecases/get_pick_by_id_usecase.dart';
import 'package:peerpicks/features/picks/domain/usecases/get_picks_by_category_usecase.dart';
import 'package:peerpicks/features/picks/domain/usecases/get_user_picks_usecase.dart';
import 'package:peerpicks/features/picks/domain/usecases/search_picks_usecase.dart';
import 'package:peerpicks/features/picks/domain/usecases/update_pick_usecase.dart';
import 'package:peerpicks/features/picks/data/repositories/picks_repository.dart';
import 'package:peerpicks/features/picks/presentation/state/picks_state.dart';

final picksViewModelProvider = NotifierProvider<PicksViewModel, PicksState>(
  PicksViewModel.new,
);

class PicksViewModel extends Notifier<PicksState> {
  late final GetDiscoveryFeedUsecase _getDiscoveryFeedUsecase;
  late final CreatePickUsecase _createPickUsecase;
  late final GetPickByIdUsecase _getPickByIdUsecase;
  late final DeletePickUsecase _deletePickUsecase;
  late final UpdatePickUsecase _updatePickUsecase;
  late final GetPicksByCategoryUsecase _getPicksByCategoryUsecase;
  late final GetUserPicksUsecase _getUserPicksUsecase;
  late final SearchPicksUsecase _searchPicksUsecase;

  @override
  PicksState build() {
    _getDiscoveryFeedUsecase = ref.read(getDiscoveryFeedUsecaseProvider);
    _createPickUsecase = ref.read(createPickUsecaseProvider);
    _getPickByIdUsecase = ref.read(getPickByIdUsecaseProvider);
    _deletePickUsecase = ref.read(deletePickUsecaseProvider);
    _updatePickUsecase = ref.read(updatePickUsecaseProvider);
    _getPicksByCategoryUsecase = ref.read(getPicksByCategoryUsecaseProvider);
    _getUserPicksUsecase = ref.read(getUserPicksUsecaseProvider);
    _searchPicksUsecase = ref.read(searchPicksUsecaseProvider);

    return const PicksState();
  }

  Future<void> getDiscoveryFeed({int page = 1, int limit = 10}) async {
    state = state.copyWith(status: PicksStatus.loading);

    final result = await _getDiscoveryFeedUsecase(
      GetDiscoveryFeedParams(page: page, limit: limit),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (picks) =>
          state = state.copyWith(status: PicksStatus.loaded, picks: picks),
    );
  }

  Future<void> createPick({
    required String alias,
    required double lat,
    required double lng,
    required String description,
    required double stars,
    required List<File> mediaFiles,
    String? category,
    String? parentPickId,
  }) async {
    state = state.copyWith(status: PicksStatus.loading);

    final result = await _createPickUsecase(
      CreatePickParams(
        alias: alias,
        lat: lat,
        lng: lng,
        description: description,
        stars: stars,
        mediaFiles: mediaFiles,
        category: category,
        parentPickId: parentPickId,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (pick) => state = state.copyWith(
        status: PicksStatus.created,
        selectedPick: pick,
        picks: [pick, ...state.picks],
      ),
    );
  }

  Future<void> getPickById(String id) async {
    state = state.copyWith(status: PicksStatus.loading);

    final result = await _getPickByIdUsecase(GetPickByIdParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (pick) => state = state.copyWith(
        status: PicksStatus.loaded,
        selectedPick: pick,
      ),
    );
  }

  Future<void> deletePick(String id) async {
    state = state.copyWith(status: PicksStatus.loading);

    final result = await _deletePickUsecase(DeletePickParams(id: id));

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: PicksStatus.deleted,
        picks: state.picks.where((pick) => pick.id != id).toList(),
      ),
    );
  }

  Future<void> updatePick({
    required String id,
    required String alias,
    required String description,
    required double stars,
  }) async {
    state = state.copyWith(status: PicksStatus.loading);

    final result = await _updatePickUsecase(
      UpdatePickParams(
        id: id,
        alias: alias,
        description: description,
        stars: stars,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (updatedPick) {
        final updatedList = state.picks
            .map((pick) => pick.id == id ? updatedPick : pick)
            .toList();
        state = state.copyWith(
          status: PicksStatus.updated,
          picks: updatedList,
          selectedPick: state.selectedPick?.id == id
              ? updatedPick
              : state.selectedPick,
        );
      },
    );
  }

  Future<void> getPicksByCategory(String category, {int page = 1}) async {
    state = state.copyWith(status: PicksStatus.loading);

    final result = await _getPicksByCategoryUsecase(
      GetPicksByCategoryParams(category: category, page: page),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (picks) =>
          state = state.copyWith(status: PicksStatus.loaded, picks: picks),
    );
  }

  Future<void> getUserPicks(String userId) async {
    state = state.copyWith(status: PicksStatus.loading);

    final result = await _getUserPicksUsecase(
      GetUserPicksParams(userId: userId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (picks) =>
          state = state.copyWith(status: PicksStatus.loaded, picks: picks),
    );
  }

  Future<void> getUserProfileWithPicks(String userId) async {
    state = state.copyWith(status: PicksStatus.loading);

    final repo = ref.read(picksRepositoryProvider);
    final result = await repo.getUserProfileWithPicks(userId);

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (data) {
        final profile = data['profile'] as Map<String, dynamic>;
        final picks = data['picks'] as List;
        state = state.copyWith(
          status: PicksStatus.loaded,
          picks: picks.cast(),
          viewedUserProfile: profile,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> searchPicks(String query, {int page = 1, int limit = 20}) async {
    state = state.copyWith(status: PicksStatus.loading);

    final result = await _searchPicksUsecase(
      SearchPicksParams(query: query, page: page, limit: limit),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: PicksStatus.error,
        errorMessage: failure.message,
      ),
      (picks) =>
          state = state.copyWith(status: PicksStatus.loaded, picks: picks),
    );
  }
}
