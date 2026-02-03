import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class GetAllCategoriesUseCase
    extends
        Use_Case<Either<AppError, List<CategoryEntity?>>, SQLiteQueryParams> {
  final CategoryRepository _categoryRepository;

  GetAllCategoriesUseCase(this._categoryRepository);

  @override
  Future<Either<AppError, List<CategoryEntity?>>> call(
    SQLiteQueryParams params,
  ) async {
    try {
      final result = await _categoryRepository.getCategoriesDomain(
        {},
        params,
        params.is_filtered,
      );
      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
