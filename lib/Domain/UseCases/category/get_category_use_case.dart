import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class GetCategoryUseCase
    extends Use_Case<Either<AppError, CategoryEntity>, CategoryEntity> {
  final CategoryRepository _categoryRepository;

  GetCategoryUseCase(this._categoryRepository);

  @override
  Future<Either<AppError, CategoryEntity>> call(CategoryEntity params) async {
    try {
      final result = await _categoryRepository.getCategoryDomain(
        params.toJson(),
      );
      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
