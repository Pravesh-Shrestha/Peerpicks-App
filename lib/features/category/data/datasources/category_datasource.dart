
import 'package:peerpicks/features/category/data/models/category_hive_model.dart';

abstract interface class ICategoryDataSource {
  Future<List<CategoryHiveModel>> getAllCategories();
  Future<CategoryHiveModel?> getCategoryById(String categoryId);
  Future<bool> createCategory(CategoryHiveModel category);
  Future<bool> updateCategory(CategoryHiveModel category);
  Future<bool> deleteCategory(String categoryId);
}
