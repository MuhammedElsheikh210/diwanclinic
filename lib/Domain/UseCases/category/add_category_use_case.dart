import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class AddCategoryUseCase
    extends Use_Case<Either<AppError, SuccessModel>, CategoryEntity> {
  final CategoryRepository _categoryRepository;

  AddCategoryUseCase(this._categoryRepository);

  @override
  Future<Either<AppError, SuccessModel>> call(CategoryEntity params) async {
    try {
      final result = await _categoryRepository.addCategoryDomain(
        params.toJson(),
        params.key ?? "",
      );
      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
