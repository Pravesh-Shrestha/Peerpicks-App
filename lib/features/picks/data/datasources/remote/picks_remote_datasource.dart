import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/api/api_client.dart';
import 'package:peerpicks/core/api/api_endpoints.dart';
import 'package:peerpicks/features/picks/data/datasources/picks_datasource.dart';
import 'package:peerpicks/features/picks/data/models/pick_model.dart';
import 'package:dio/dio.dart';

final picksRemoteDataSourceProvider = Provider<IPicksDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PicksRemoteDataSourceImpl(client: apiClient);
});

class PicksRemoteDataSourceImpl implements IPicksDataSource {
  final ApiClient client;

  PicksRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PickModel>> getDiscoveryFeed({
    required int page,
    required int limit,
  }) async {
    final response = await client.get(
      ApiEndpoints.discoveryFeed,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'] as List;
      return data.map((json) => PickModel.fromJson(json)).toList();
    }

    return [];
  }

  @override
  Future<PickModel> createPick({
    required String alias,
    required double lat,
    required double lng,
    required String description,
    required double stars,
    required List<File> mediaFiles,
    String? category,
    String? parentPickId,
  }) async {
    // Matching backend pickController logic for JSON.parse(req.body.placeInfo)
    final placeInfo = jsonEncode({
      'name': alias, // Backend uses placeData.name as placeId
      'alias': alias,
      'lat': lat,
      'lng': lng,
      'category': category ?? 'General',
    });

    final reviewInfo = jsonEncode({
      'description': description,
      'stars': stars,
      'category': category,
      'parentPickId': parentPickId,
    });

    final formData = FormData.fromMap({
      'placeInfo': placeInfo,
      'reviewInfo': reviewInfo,
      'images': await Future.wait(
        mediaFiles.map(
          (file) async => await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      ),
    });

    final response = await client.post(
      ApiEndpoints.picks,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.statusCode == 201) {
      return PickModel.fromJson(response.data['data']);
    }

    return PickModel(
      id: '',
      userId: '',
      placeId: '',
      alias: alias,
      stars: stars,
      description: description,
      mediaUrls: const [],
      upvoteCount: 0,
      downvoteCount: 0,
      commentCount: 0,
      latitude: lat,
      longitude: lng,
      createdAt: DateTime.now(),
      tags: const [],
    );
  }

  @override
  Future<PickModel?> getPickById(String id) async {
    final response = await client.get(ApiEndpoints.pickDetail(id));

    if (response.statusCode == 200) {
      return PickModel.fromJson(response.data['data']);
    }

    return null;
  }

  @override
  Future<PickModel> updatePick({
    required String id,
    required String alias,
    required String description,
    required double stars,
  }) async {
    final response = await client.patch(
      ApiEndpoints.updatePick(id),
      data: {'alias': alias, 'description': description, 'stars': stars},
    );

    if (response.statusCode == 200) {
      return PickModel.fromJson(response.data['data']);
    }

    return PickModel(
      id: id,
      userId: '',
      placeId: '',
      alias: alias,
      stars: stars,
      description: description,
      mediaUrls: const [],
      upvoteCount: 0,
      downvoteCount: 0,
      commentCount: 0,
      latitude: 0,
      longitude: 0,
      createdAt: DateTime.now(),
      tags: const [],
    );
  }

  @override
  Future<bool> deletePick(String id) async {
    final response = await client.delete(ApiEndpoints.deletePick(id));
    return response.statusCode == 200;
  }

  @override
  Future<List<PickModel>> getPicksByCategory(
    String category, {
    int page = 1,
  }) async {
    final response = await client.get(
      ApiEndpoints.picksByCategory(category),
      queryParameters: {'page': page},
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'] as List;
      return data.map((json) => PickModel.fromJson(json)).toList();
    }

    return [];
  }

  @override
  Future<List<PickModel>> getUserPicks(String userId) async {
    final response = await client.get(ApiEndpoints.picksByUser(userId));

    if (response.statusCode == 200) {
      final picksPayload = response.data['data'];
      final List picksData = picksPayload is Map<String, dynamic>
          ? (picksPayload['picks'] as List? ?? [])
          : (picksPayload as List? ?? []);
      return picksData.map((json) => PickModel.fromJson(json)).toList();
    }

    return [];
  }

  @override
  Future<Map<String, dynamic>> getUserProfileWithPicks(String userId) async {
    final response = await client.get(ApiEndpoints.picksByUser(userId));

    if (response.statusCode == 200) {
      final payload = response.data['data'];
      if (payload is Map<String, dynamic>) {
        final List picksData = payload['picks'] as List? ?? [];
        final picks = picksData
            .map((json) => PickModel.fromJson(json))
            .toList();
        final profile = payload['profile'] as Map<String, dynamic>? ?? {};
        return {'profile': profile, 'picks': picks};
      }
    }
    return {'profile': <String, dynamic>{}, 'picks': <PickModel>[]};
  }

  @override
  Future<List<PickModel>> searchPicks({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await client.get(
      ApiEndpoints.searchPicks,
      queryParameters: {'q': query, 'page': page, 'limit': limit},
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'] as List;
      return data.map((json) => PickModel.fromJson(json)).toList();
    }

    return [];
  }
}
