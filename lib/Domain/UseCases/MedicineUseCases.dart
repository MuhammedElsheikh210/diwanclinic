import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class MedicineUseCases {
  final MedicineRepository _repository;

  MedicineUseCases(this._repository);

  Future<Either<AppError, List<MedicineModel>>> searchMedicines(
      String keyword,
      ) {
    return _repository.searchMedicinesDomain(keyword);
  }

  Future<Either<AppError, void>> updateMedicinePrice(int id, double price) {
    return _repository.updateMedicinePriceDomain(id, price);
  }
}
