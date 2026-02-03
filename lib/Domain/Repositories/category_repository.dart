import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class CategoryRepository {
  /// 🔍 Fetch a list of categories with optional filtering
  Future<Either<AppError, List<CategoryEntity?>>> getCategoriesDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  /// 📌 Fetch a single category
  Future<Either<AppError, CategoryEntity>> getCategoryDomain(
    Map<String, dynamic> data,
  );

  /// ➕ Add a new category
  Future<Either<AppError, SuccessModel>> addCategoryDomain(
    Map<String, dynamic> data,
    String id,
  );

  /// 🗑 Delete a category
  Future<Either<AppError, SuccessModel>> deleteCategoryDomain(
    Map<String, dynamic> data,
    String id,
  );

  /// 🔄 Update a category
  Future<Either<AppError, SuccessModel>> updateCategoryDomain(
    Map<String, dynamic> data,
    String id,
  );

  /// 🚀 Bulk Insert Categories
  Future<Either<AppError, SuccessModel>> addBulkCategoriesDomain(
    List<Map<String, dynamic>> data,
  );
}
