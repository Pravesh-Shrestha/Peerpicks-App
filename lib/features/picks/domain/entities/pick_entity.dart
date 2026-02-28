import 'package:equatable/equatable.dart';

class PickEntity extends Equatable {
  final String id;
  final String userId;
  final String placeId;
  final String alias;
  final double stars;
  final String description;
  final List<String> mediaUrls;
  final List<String> tags;
  final String? category;

  // User info (populated from backend)
  final String? userName;
  final String? userProfilePicture;

  // Place / location info
  final String? locationName;
  final bool hasUpvoted;

  // Social Engagement Fields
  final int upvoteCount;
  final int downvoteCount;
  final int commentCount;

  // Location Data (Mapped from GeoJSON)
  final double latitude;
  final double longitude;

  final DateTime createdAt;

  const PickEntity({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.alias,
    required this.stars,
    required this.description,
    required this.mediaUrls,
    required this.tags,
    this.category,
    this.userName,
    this.userProfilePicture,
    this.locationName,
    this.hasUpvoted = false,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.commentCount,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    upvoteCount,
    downvoteCount,
    commentCount,
    alias,
    stars,
    hasUpvoted,
  ];
}
