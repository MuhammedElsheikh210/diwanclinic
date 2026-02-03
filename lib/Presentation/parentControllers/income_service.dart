// ignore_for_file: avoid_renaming_method_parameters


import '../../index/index_main.dart';

class IncomeService {
  final IncomeUseCases useCase = initController(
        () => IncomeUseCases(Get.find()),
  );

  Future<void> addIncomeData({
    required IncomeModel income,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addIncome(income);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateIncomeData({
    required IncomeModel income,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateIncome(income);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteIncomeData({
    required String incomeKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteIncome(incomeKey);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> getIncomesData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<IncomeModel?>) voidCallBack,
  }) async {
    final result = await useCase.getIncomes(data, query, isFiltered);
    result.fold(
          (l) => Loader.showError("Something went wrong"),
          (r) => voidCallBack(r),
    );
  }
}
