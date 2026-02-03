import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  final CategoryDataSourceRepo _categoryDataSourceRepo;

  CategoryRepositoryImpl(this._categoryDataSourceRepo);

  @override
  Future<Either<AppError, List<CategoryEntity?>>> getCategoriesDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final result = await _categoryDataSourceRepo.getCategories(
        data,
        query,
        isFiltered,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, CategoryEntity>> getCategoryDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _categoryDataSourceRepo.getCategory(data);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addCategoryDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _categoryDataSourceRepo.addCategory(data, id);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteCategoryDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _categoryDataSourceRepo.deleteCategory(data, id);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateCategoryDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _categoryDataSourceRepo.updateCategory(data, id);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addBulkCategoriesDomain(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final result = await _categoryDataSourceRepo.addBulkCategories(data);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
