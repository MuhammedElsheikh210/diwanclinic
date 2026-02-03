import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class MedicineRepositoryImpl extends MedicineRepository {
  final MedicineDataSourceRepo _medicineDataSourceRepo;

  MedicineRepositoryImpl(this._medicineDataSourceRepo);

  @override
  Future<Either<AppError, List<MedicineModel>>> searchMedicinesDomain(
      String keyword,
      ) async {
    try {
      final result =
      await _medicineDataSourceRepo.searchMedicines(keyword);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
