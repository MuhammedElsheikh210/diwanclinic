// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class AssistantService {
  final AssistantUseCases useCase = initController(
    () => AssistantUseCases(Get.find()),
  );

  Future<void> addAssistantData({
    required AssistantModel assistant,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addAssistant(assistant);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateAssistantData({
    required AssistantModel assistant,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateAssistant(assistant);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteAssistantData({
    required String assistantKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteAssistant(assistantKey);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> getAssistantsData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<AssistantModel?>) voidCallBack,
  }) async {
    //Loader.show();
    final result = await useCase.getAssistants(data, query, isFiltered);
    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }
}
