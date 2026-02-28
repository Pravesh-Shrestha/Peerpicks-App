import 'package:equatable/equatable.dart';
import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';

enum NearbyStatus { initial, loading, loaded, error }

class NearbyState extends Equatable {
  final NearbyStatus status;
  final List<PickEntity> nearbyPicks;
  final String? errorMessage;
  final double? currentLat;
  final double? currentLng;

  const NearbyState({
    this.status = NearbyStatus.initial,
    this.nearbyPicks = const [],
    this.errorMessage,
    this.currentLat,
    this.currentLng,
  });

  NearbyState copyWith({
    NearbyStatus? status,
    List<PickEntity>? nearbyPicks,
    String? errorMessage,
    double? currentLat,
    double? currentLng,
  }) {
    return NearbyState(
      status: status ?? this.status,
      nearbyPicks: nearbyPicks ?? this.nearbyPicks,
      errorMessage: errorMessage ?? this.errorMessage,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
    );
  }

  @override
  List<Object?> get props => [
    status,
    nearbyPicks,
    errorMessage,
    currentLat,
    currentLng,
  ];
}
