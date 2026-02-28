import 'dart:io';

import 'package:peerpicks/features/picks/data/models/pick_model.dart';

abstract interface class IPicksDataSource {
  Future<List<PickModel>> getDiscoveryFeed({
    required int page,
    required int limit,
  });

  Future<PickModel> createPick({
    required String alias,
    required double lat,
    required double lng,
    required String description,
    required double stars,
    required List<File> mediaFiles,
    String? category,
    String? parentPickId,
  });

  Future<PickModel?> getPickById(String id);
  Future<bool> deletePick(String id);
  Future<List<PickModel>> getPicksByCategory(String category, {int page = 1});
  Future<List<PickModel>> getUserPicks(String userId);
  Future<Map<String, dynamic>> getUserProfileWithPicks(String userId);
  Future<List<PickModel>> searchPicks({
    required String query,
    int page = 1,
    int limit = 20,
  });
}
