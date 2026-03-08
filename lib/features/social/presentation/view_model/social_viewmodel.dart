import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';
import 'package:peerpicks/features/picks/presentation/view_model/picks_viewmodel.dart';
import 'package:peerpicks/features/social/data/repositories/social_repository.dart';
import 'package:peerpicks/features/social/domain/repositories/social_repository.dart';
import 'package:peerpicks/features/social/presentation/state/social_state.dart';

final socialViewModelProvider = NotifierProvider<SocialViewModel, SocialState>(
  SocialViewModel.new,
);

class SocialViewModel extends Notifier<SocialState> {
  late final ISocialRepository _socialRepository;
  final Set<String> _voteInFlight = <String>{};
  final Set<String> _followInFlight = <String>{};

  @override
  SocialState build() {
    _socialRepository = ref.read(socialRepositoryProvider);
    return const SocialState();
  }

  // ============ SYNC FROM SERVER DATA ============
  /// Populate votedPickIds from picks that have hasUpvoted=true
  void syncVotedFromPicks(List<PickEntity> picks) {
    final voted = Set<String>.from(state.votedPickIds);
    for (final pick in picks) {
      if (pick.hasUpvoted) {
        voted.add(pick.id);
      }
    }
    if (voted.length != state.votedPickIds.length ||
        !voted.containsAll(state.votedPickIds)) {
      state = state.copyWith(votedPickIds: voted);
    }
  }

  // ============ VOTING ============
  Future<void> toggleVote(String pickId) async {
    if (_voteInFlight.contains(pickId)) {
      return;
    }
    _voteInFlight.add(pickId);

    // Optimistic update
    final currentVoted = Set<String>.from(state.votedPickIds);
    if (currentVoted.contains(pickId)) {
      currentVoted.remove(pickId);
    } else {
      currentVoted.add(pickId);
    }
    state = state.copyWith(votedPickIds: currentVoted);

    final result = await _socialRepository.toggleVote(pickId);
    result.fold(
      (failure) {
        // Rollback
        final rollback = Set<String>.from(state.votedPickIds);
        if (rollback.contains(pickId)) {
          rollback.remove(pickId);
        } else {
          rollback.add(pickId);
        }
        state = state.copyWith(
          votedPickIds: rollback,
          errorMessage: failure.message,
        );
        _voteInFlight.remove(pickId);
      },
      (voteData) {
        final isUpvoted = voteData['isUpvoted'] == true;
        final upvoteCount = (voteData['upvoteCount'] as num?)?.toInt() ?? 0;

        // Sync with server truth
        final synced = Set<String>.from(state.votedPickIds);
        if (isUpvoted) {
          synced.add(pickId);
        } else {
          synced.remove(pickId);
        }
        state = state.copyWith(votedPickIds: synced);

        ref
            .read(picksViewModelProvider.notifier)
            .syncVoteForPick(
              pickId: pickId,
              isUpvoted: isUpvoted,
              upvoteCount: upvoteCount,
            );

        _voteInFlight.remove(pickId);
      },
    );
  }

  /// Sync follow state from a user-profile server response
  void syncFollowFromProfile(String userId, bool isFollowing) {
    final updated = Set<String>.from(state.followedUserIds);
    if (isFollowing) {
      updated.add(userId);
    } else {
      updated.remove(userId);
    }
    if (updated.length != state.followedUserIds.length ||
        !updated.containsAll(state.followedUserIds)) {
      state = state.copyWith(followedUserIds: updated);
    }
  }

  // ============ FOLLOW ============
  Future<void> toggleFollow(String targetUserId) async {
    if (_followInFlight.contains(targetUserId)) {
      return;
    }
    _followInFlight.add(targetUserId);

    final currentFollowed = Set<String>.from(state.followedUserIds);
    if (currentFollowed.contains(targetUserId)) {
      currentFollowed.remove(targetUserId);
    } else {
      currentFollowed.add(targetUserId);
    }
    state = state.copyWith(followedUserIds: currentFollowed);

    final result = await _socialRepository.toggleFollow(targetUserId);
    result.fold(
      (failure) {
        final rollback = Set<String>.from(state.followedUserIds);
        if (rollback.contains(targetUserId)) {
          rollback.remove(targetUserId);
        } else {
          rollback.add(targetUserId);
        }
        state = state.copyWith(
          followedUserIds: rollback,
          errorMessage: failure.message,
        );
        _followInFlight.remove(targetUserId);
      },
      (data) {
        final isFollowing = data['isFollowing'] as bool;
        final updated = Set<String>.from(state.followedUserIds);
        if (isFollowing) {
          updated.add(targetUserId);
        } else {
          updated.remove(targetUserId);
        }
        state = state.copyWith(
          followedUserIds: updated,
          // Store latest counts so the profile screen can read them
          lastFollowCounts: {
            'followerCount': data['followerCount'],
            'followingCount': data['followingCount'],
          },
        );
        _followInFlight.remove(targetUserId);
      },
    );
  }

  // ============ FAVORITES ============
  Future<void> toggleFavorite(String pickId) async {
    final currentFavorited = Set<String>.from(state.favoritedPickIds);
    if (currentFavorited.contains(pickId)) {
      currentFavorited.remove(pickId);
    } else {
      currentFavorited.add(pickId);
    }
    state = state.copyWith(favoritedPickIds: currentFavorited);

    final result = await _socialRepository.toggleFavorite(pickId);
    result.fold(
      (failure) {
        final rollback = Set<String>.from(state.favoritedPickIds);
        if (rollback.contains(pickId)) {
          rollback.remove(pickId);
        } else {
          rollback.add(pickId);
        }
        state = state.copyWith(
          favoritedPickIds: rollback,
          errorMessage: failure.message,
        );
      },
      (isSaved) {
        final updated = Set<String>.from(state.favoritedPickIds);
        if (isSaved) {
          updated.add(pickId);
        } else {
          updated.remove(pickId);
        }
        state = state.copyWith(favoritedPickIds: updated);
      },
    );
  }

  Future<void> getMyFavorites() async {
    state = state.copyWith(status: SocialStatus.loading);

    final result = await _socialRepository.getMyFavorites();
    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (picks) {
        final favIds = picks.map((p) => p.id).toSet();
        state = state.copyWith(
          status: SocialStatus.loaded,
          favorites: picks,
          favoritedPickIds: favIds,
        );
      },
    );
  }

  // ============ COMMENTS ============
  Future<void> getPickDiscussion(String pickId) async {
    state = state.copyWith(status: SocialStatus.loading);

    final result = await _socialRepository.getPickDiscussion(pickId);
    result.fold(
      (failure) => state = state.copyWith(
        status: SocialStatus.error,
        errorMessage: failure.message,
      ),
      (comments) => state = state.copyWith(
        status: SocialStatus.loaded,
        comments: comments,
      ),
    );
  }

  Future<void> createComment({
    required String pickId,
    required String content,
  }) async {
    final result = await _socialRepository.createComment(
      pickId: pickId,
      content: content,
    );
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (comment) {
        state = state.copyWith(
          status: SocialStatus.actionSuccess,
          comments: [...state.comments, comment],
          successMessage: 'Comment added',
        );
        // Re-fetch to get fully populated comments
        getPickDiscussion(pickId);
      },
    );
  }

  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    final result = await _socialRepository.updateComment(
      commentId: commentId,
      content: content,
    );
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (updated) {
        final updatedList = state.comments.map((c) {
          return c.id == commentId ? updated : c;
        }).toList();
        state = state.copyWith(
          status: SocialStatus.actionSuccess,
          comments: updatedList,
        );
      },
    );
  }

  Future<void> deleteComment(String commentId) async {
    final result = await _socialRepository.deleteComment(commentId);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        state = state.copyWith(
          status: SocialStatus.actionSuccess,
          comments: state.comments.where((c) => c.id != commentId).toList(),
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
