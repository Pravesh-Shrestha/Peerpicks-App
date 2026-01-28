import 'package:hive/hive.dart';
import 'package:peerpicks/core/constants/hive_table_constant.dart';
import 'package:peerpicks/features/category/domain/entities/category_entity.dart';
import 'package:uuid/uuid.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.categoryTypeId)
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  final String? categoryId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;


  CategoryHiveModel({
    String? categoryId,
    required this.name,
    this.description,
  })  : categoryId = categoryId ?? const Uuid().v4();
  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
      description: description,
    );
  }

  factory CategoryHiveModel.fromEntity(CategoryEntity entity) {
    return CategoryHiveModel(
      categoryId: entity.categoryId,
      name: entity.name,
      description: entity.description,
    );
  }

  static List<CategoryEntity> toEntityList(List<CategoryHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
