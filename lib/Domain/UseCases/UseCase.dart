import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../Data/Models/GenericModels/AppError.dart';

abstract class UseCase<OutPut, InPut> {
  Future<Either<AppError, OutPut>> call(InPut input);
}

abstract class Use_Case<OutPut, InPut> {
  Future<OutPut> call(InPut input);
}

// T initUseCase<T>(T Function() createInstance) {
//   return Get.isRegistered<T>() ? Get.find<T>() : Get.put(createInstance());
// }

T initController<T>(T Function() createInstance) {
  if (!Get.isRegistered<T>()) {
    Get.lazyPut<T>(createInstance, fenix: true);
  }
  return Get.find<T>();
}
