import 'package:peerpicks/features/picks/domain/entities/pick_entity.dart';

class PickModel extends PickEntity {
  const PickModel({
    required super.id,
    required super.userId,
    required super.placeId,
    required super.alias,
    required super.stars,
    required super.description,
    required super.mediaUrls,
    required super.upvoteCount,
    required super.downvoteCount,
    required super.commentCount,
    required super.latitude,
    required super.longitude,
    required super.createdAt,
    required super.tags,
    super.category,
    super.userName,
    super.userProfilePicture,
    super.locationName,
    super.hasUpvoted,
  });

  // 1. From JSON (Backend -> Model)
  factory PickModel.fromJson(Map<String, dynamic> json) {
    // MongoDB GeoJSON coordinates are [longitude, latitude]
    final List<dynamic> coords = json['location']?['coordinates'] ?? [0.0, 0.0];

    // Extract user info from populated user object
    String userId = '';
    String? userName;
    String? userProfilePicture;
    if (json['user'] is Map) {
      userId = json['user']['_id'] ?? '';
      userName = json['user']['fullName'];
      userProfilePicture = json['user']['profilePicture'];
    } else {
      userId = json['user'] ?? '';
    }

    // Extract place info
    String placeId = '';
    if (json['place'] is Map) {
      placeId = json['place']['_id'] ?? '';
    } else {
      placeId = json['place'] ?? '';
    }

    // Location name from hydrated pick or placeDetails
    String? locationName = json['locationName'];
    if (locationName == null && json['placeDetails'] is Map) {
      locationName = json['placeDetails']['name'];
    }

    return PickModel(
      id: json['_id'] ?? '',
      userId: userId,
      userName: userName,
      userProfilePicture: userProfilePicture,
      placeId: placeId,
      locationName: locationName,
      hasUpvoted: json['hasUpvoted'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      alias: json['alias'] ?? '',
      stars: (json['stars'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      upvoteCount: json['upvoteCount'] ?? 0,
      downvoteCount: json['downvoteCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      longitude: (coords[0] as num).toDouble(),
      latitude: (coords[1] as num).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // 2. To JSON (Model -> Backend)
  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'stars': stars,
      'description': description,
      'mediaUrls': mediaUrls,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
    };
  }

  // 3. From Entity (Domain -> Model)
  factory PickModel.fromEntity(PickEntity entity) {
    return PickModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userProfilePicture: entity.userProfilePicture,
      placeId: entity.placeId,
      locationName: entity.locationName,
      hasUpvoted: entity.hasUpvoted,
      alias: entity.alias,
      stars: entity.stars,
      description: entity.description,
      mediaUrls: entity.mediaUrls,
      upvoteCount: entity.upvoteCount,
      downvoteCount: entity.downvoteCount,
      commentCount: entity.commentCount,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdAt: entity.createdAt,
      tags: entity.tags,
      category: entity.category,
    );
  }

  // 4. To Entity (Model -> Domain)
  PickEntity toEntity() {
    return PickEntity(
      id: id,
      userId: userId,
      userName: userName,
      userProfilePicture: userProfilePicture,
      placeId: placeId,
      locationName: locationName,
      hasUpvoted: hasUpvoted,
      alias: alias,
      stars: stars,
      description: description,
      mediaUrls: mediaUrls,
      upvoteCount: upvoteCount,
      downvoteCount: downvoteCount,
      commentCount: commentCount,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      tags: tags,
      category: category,
    );
  }

  static List<PickEntity> toEntityList(List<PickModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
