import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/services/hive/hive_service.dart';
import 'package:peerpicks/features/category/data/datasources/category_datasource.dart';
import 'package:peerpicks/features/category/data/models/category_hive_model.dart';



final categoryLocalDatasourceProvider = Provider<CategoryLocalDatasource>((
  ref,
) {
  final hiveService = ref.read(hiveServiceProvider);
  return CategoryLocalDatasource(hiveService: hiveService);
});

class CategoryLocalDatasource implements ICategoryDataSource {
  final HiveService _hiveService;

  CategoryLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> createCategory(CategoryHiveModel category) async {
    try {
      await _hiveService.createCategory(category);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _hiveService.deleteCategory(categoryId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<CategoryHiveModel>> getAllCategories() async {
    try {
      return _hiveService.getAllCategories();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryHiveModel?> getCategoryById(String categoryId) async {
    try {
      return _hiveService.getCategoryById(categoryId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateCategory(CategoryHiveModel category) async {
    try {
      await _hiveService.updateCategory(category);
      return true;
    } catch (e) {
      return false;
    }
  }
}
