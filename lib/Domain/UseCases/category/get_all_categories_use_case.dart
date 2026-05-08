import 'package:dartz/dartz.dart';

import '../../../index/index_main.dart';

class GetAllCategoriesUseCase
    extends
        Use_Case<
          Either<AppError, List<CategoryEntity?>>,
          Map<String, dynamic>
        > {
  final CategoryRepository _categoryRepository;

  GetAllCategoriesUseCase(this._categoryRepository);

  @override
  Future<Either<AppError, List<CategoryEntity?>>> call(
    Map<String, dynamic> params,
  ) async {
    try {
      final result = await _categoryRepository.getCategoriesDomain(
        params['data'] ?? {},

        params['query'] ?? SQLiteQueryParams(),

        params['isFiltered'],
      );

      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
