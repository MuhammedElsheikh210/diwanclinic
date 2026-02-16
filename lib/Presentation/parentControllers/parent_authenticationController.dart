// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class AuthenticationService {
  final AuthenticationUseCases useCase = initController(
    () => AuthenticationUseCases(Get.find()),
  );

  Future<void> addClientsData({
    required LocalUser userclient,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addClient(userclient);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> clearLocalClients() async {
    final db = await DatabaseService().database;

    await db.delete("clients");
  }

  Future<void> updateClientsData({
    required LocalUser userclient,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateClient(userclient);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteClientsData({
    required String uid,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteClient(uid);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> getSingleClientsData({
    required FirebaseFilter filrebaseFilter,
    required Function(LocalUser?) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.getClientIndividual(filrebaseFilter.toJson());
    result.fold(
      (l) => Loader.showError("Something went wrong: ${l.messege}"),
      (r) => voidCallBack(r),
    );
  }

  Future<void> getClientsData({
    String? keyFilter,
    String? filterValue,
    FirebaseFilter? firebaseFilter,
    SQLiteQueryParams? query,
    bool? isFiltered,
    required Function(List<LocalUser?>) voidCallBack,
  }) async {
    final Map<String, dynamic> data = keyFilter != null
        ? {keyFilter: filterValue}
        : {};

    final SQLiteQueryParams safeQuery = query ?? SQLiteQueryParams();

    final result = await useCase.getClients(
      data: firebaseFilter == null ? data : firebaseFilter.toJson(),
      query: safeQuery,
      isFiltered: isFiltered,
    );

    result.fold((l) async {
      Loader.showError("⚠️ Network issue — loading offline data...");
      final localResult = await useCase.getClientsLocal(
        data: firebaseFilter == null ? data : firebaseFilter.toJson(),
        query: safeQuery,
        isFiltered: isFiltered,
      );
      localResult.fold(
        (le) => Loader.showError("❌ Failed to load offline data"),
        (lr) => voidCallBack(lr),
      );
    }, (r) => voidCallBack(r));
  }

  Future<void> getClientsLocalData({
    SQLiteQueryParams? query,
    bool? isFiltered,
    required Function(List<LocalUser?>) voidCallBack,
  }) async {
    final SQLiteQueryParams safeQuery = query ?? SQLiteQueryParams();
    final result = await useCase.getClientsLocal(
      data: const {},
      query: safeQuery,
      isFiltered: isFiltered,
    );

    result.fold(
      (l) => Loader.showError("❌ Failed to load local clients"),
      (r) => voidCallBack(r),
    );
  }
}
