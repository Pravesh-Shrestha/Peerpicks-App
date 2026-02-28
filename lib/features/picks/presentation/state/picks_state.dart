import 'package:equatable/equatable.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';

enum PicksStatus { initial, loading, loaded, error, created, updated, deleted }

class PicksState extends Equatable {
  final PicksStatus status;
  final List<PickEntity> picks;
  final PickEntity? selectedPick;
  final String? errorMessage;

  // User profile data (for UserProfileViewScreen)
  final Map<String, dynamic>? viewedUserProfile;

  const PicksState({
    this.status = PicksStatus.initial,
    this.picks = const [],
    this.selectedPick,
    this.errorMessage,
    this.viewedUserProfile,
  });

  PicksState copyWith({
    PicksStatus? status,
    List<PickEntity>? picks,
    PickEntity? selectedPick,
    String? errorMessage,
    Map<String, dynamic>? viewedUserProfile,
  }) {
    return PicksState(
      status: status ?? this.status,
      picks: picks ?? this.picks,
      selectedPick: selectedPick ?? this.selectedPick,
      errorMessage: errorMessage ?? this.errorMessage,
      viewedUserProfile: viewedUserProfile ?? this.viewedUserProfile,
    );
  }

  @override
  List<Object?> get props => [
    status,
    picks,
    selectedPick,
    errorMessage,
    viewedUserProfile,
  ];
}
