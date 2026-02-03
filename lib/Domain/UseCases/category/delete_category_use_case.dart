import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class DeleteCategoryUseCase
    extends Use_Case<Either<AppError, SuccessModel>, CategoryEntity> {
  final CategoryRepository _categoryRepository;

  DeleteCategoryUseCase(this._categoryRepository);

  @override
  Future<Either<AppError, SuccessModel>> call(
    CategoryEntity categoryEntity,
  ) async {
    try {
      final result = await _categoryRepository.deleteCategoryDomain(
        {},
        categoryEntity.key ?? "",
      );
      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
