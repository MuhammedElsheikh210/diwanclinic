import 'package:get/get.dart';
import '../Constatnts/TextConstants.dart';
import 'StorageService.dart';

class ForceUpdate extends GetxController {
  Future<bool> saveAlreadyOpen(bool isUpdate) {
    return StorageService().setData(Strings.force_update, isUpdate);
  }

  bool getOpen() {
    return StorageService().getData(Strings.force_update);
  }
}
