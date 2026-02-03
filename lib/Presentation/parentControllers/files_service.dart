// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class FilesService {
  final FilesUseCases useCase = initController(
        () => FilesUseCases(Get.find()),
  );

  Future<void> addFileData({
    required FilesModel file,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addFile(file);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updateFileData({
    required FilesModel file,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateFile(file);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deleteFileData({
    required String fileKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteFile(fileKey);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> getFilesData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<FilesModel?>) voidCallBack,
  }) async {
   // Loader.show();
    final result = await useCase.getFiles(data, query, isFiltered);
    result.fold(
          (l) => Loader.showError("Something went wrong"),
          (r) => voidCallBack(r),
    );
  }
}
