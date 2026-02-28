import 'package:equatable/equatable.dart';
import 'package:peerpicks/features/social/domain/entities/comment_entity.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';

enum SocialStatus { initial, loading, loaded, error, actionSuccess }

class SocialState extends Equatable {
  final SocialStatus status;
  final List<PickEntity> favorites;
  final List<CommentEntity> comments;
  final String? errorMessage;
  final String? successMessage;

  // Track per-pick states for optimistic UI
  final Set<String> votedPickIds;
  final Set<String> favoritedPickIds;
  final Set<String> followedUserIds;

  /// Counts returned by the last follow/unfollow toggle
  final Map<String, dynamic>? lastFollowCounts;

  const SocialState({
    this.status = SocialStatus.initial,
    this.favorites = const [],
    this.comments = const [],
    this.errorMessage,
    this.successMessage,
    this.votedPickIds = const {},
    this.favoritedPickIds = const {},
    this.followedUserIds = const {},
    this.lastFollowCounts,
  });

  SocialState copyWith({
    SocialStatus? status,
    List<PickEntity>? favorites,
    List<CommentEntity>? comments,
    String? errorMessage,
    String? successMessage,
    Set<String>? votedPickIds,
    Set<String>? favoritedPickIds,
    Set<String>? followedUserIds,
    Map<String, dynamic>? lastFollowCounts,
  }) {
    return SocialState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      comments: comments ?? this.comments,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      votedPickIds: votedPickIds ?? this.votedPickIds,
      favoritedPickIds: favoritedPickIds ?? this.favoritedPickIds,
      followedUserIds: followedUserIds ?? this.followedUserIds,
      lastFollowCounts: lastFollowCounts ?? this.lastFollowCounts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    favorites,
    comments,
    errorMessage,
    successMessage,
    votedPickIds,
    favoritedPickIds,
    followedUserIds,
    lastFollowCounts,
  ];
}
