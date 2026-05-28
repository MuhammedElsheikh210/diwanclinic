import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class MedicineRepository {
  Future<Either<AppError, List<MedicineModel>>> searchMedicinesDomain(
      String keyword,
      );
  Future<Either<AppError, void>> updateMedicinePriceDomain(int id, double price);
}
