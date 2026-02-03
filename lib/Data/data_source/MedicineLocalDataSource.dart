import 'package:diwanclinic/Data/Models/medicine_model.dart';

abstract class MedicineDataSourceRepo {
  Future<List<MedicineModel>> searchMedicines(String keyword);
}
