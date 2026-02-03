// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class DoctorSuggestionService {
  final DoctorSuggestionUseCases useCase = initController(
    () => DoctorSuggestionUseCases(Get.find()),
  );

  /// 🔹 Add a new doctor suggestion
  Future<void> addDoctorSuggestionData({
    required DoctorSuggestionModel suggestion,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addDoctorSuggestion(suggestion);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔹 Update existing doctor suggestion
  Future<void> updateDoctorSuggestionData({
    required DoctorSuggestionModel suggestion,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateDoctorSuggestion(suggestion);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔹 Delete doctor suggestion
  Future<void> deleteDoctorSuggestionData({
    required String suggestionKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteDoctorSuggestion(suggestionKey);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// 🔹 Get all doctor suggestions
  Future<void> getDoctorSuggestionsData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    required FirebaseFilter firebaseFilter,
    bool? isFiltered,
    required Function(List<DoctorSuggestionModel?>) voidCallBack,
  }) async {
    // Loader.show(); // optional — can be commented out like in your example
    final result = await useCase.getDoctorSuggestions(
      firebaseFilter.toJson(),
      query,
      isFiltered,
    );

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }
}
