// ignore_for_file: avoid_renaming_method_parameters

import 'package:diwanclinic/Domain/UseCases/base_use_cases.dart';

import '../../index/index_main.dart';

class BaseService<T> {
  final BaseUseCases<T> useCase;

  BaseService(this.useCase);

  /// =========================
  /// ADD
  /// =========================
  Future<void> addData({
    required T item,
    required Map<String, dynamic> Function(T item) toJson,
    required String id,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.addItem(item, toJson, id);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// =========================
  /// UPDATE
  /// =========================
  Future<void> updateData({
    required T item,
    required Map<String, dynamic> Function(T item) toJson,
    required String id,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.updateItem(item, toJson, id);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// =========================
  /// DELETE
  /// =========================
  Future<void> deleteData({
    required String id,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.deleteItem(id);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  /// =========================
  /// GET ALL
  /// =========================
  Future<void> getData({
    required Map<String, dynamic> data,
    required Function(List<T?>) voidCallBack,
  }) async {
    final result = await useCase.getItems(data);

    result.fold(
      (l) => Loader.showError("Something went wrong"),
      (r) => voidCallBack(r),
    );
  }
}
