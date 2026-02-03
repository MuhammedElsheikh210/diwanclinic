import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class UpdateCategoryUseCase
    extends Use_Case<Either<AppError, SuccessModel>, CategoryEntity> {
  final CategoryRepository _categoryRepository;

  UpdateCategoryUseCase(this._categoryRepository);

  @override
  Future<Either<AppError, SuccessModel>> call(CategoryEntity params) async {
    try {
      final result = await _categoryRepository.updateCategoryDomain(
        params.toJson(),
        params.key ?? "",
      );
      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
