import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class CategoryService {
  // Add Category
  Future<void> addCategoryData({
    required CategoryEntity category,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    AddCategoryUseCase addCategoryUseCase = initController(
      () => AddCategoryUseCase(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await addCategoryUseCase.call(
      category,
    );

    result.fold((l) => Loader.showError(l.messege), (r) {
      return voidCallBack(ResponseStatus.success);
    });

    Loader.dismiss();
  }

  // Update Category
  Future<void> updateCategoryData({
    required CategoryEntity category,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    UpdateCategoryUseCase updateCategoryUseCase = initController(
      () => UpdateCategoryUseCase(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await updateCategoryUseCase
        .call(category);

    result.fold((l) => Loader.showError(l.messege), (r) {
      return voidCallBack(ResponseStatus.success);
    });

    Loader.dismiss();
  }

  // Delete Category
  Future<void> deleteCategoryData({
    required CategoryEntity category_entity,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    DeleteCategoryUseCase deleteCategoryUseCase = initController(
      () => DeleteCategoryUseCase(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await deleteCategoryUseCase
        .call(category_entity);

    result.fold((l) => Loader.showError(l.messege), (r) {
      return voidCallBack(ResponseStatus.success);
    });

    Loader.dismiss();
  }

  // Get All Categories
  Future<void> getAllCategoriesData({
    required Function(List<CategoryEntity?>) voidCallBack,
    SQLiteQueryParams? filterParams,
  }) async {
    GetAllCategoriesUseCase getAllCategoriesUseCase = initController(
      () => GetAllCategoriesUseCase(Get.find()),
    );

    final Either<AppError, List<CategoryEntity?>> result =
        await getAllCategoriesUseCase.call(filterParams ?? SQLiteQueryParams());

    result.fold(
      (l) {
        print("l error is ${l.messege}");
        return Loader.showError(l.messege);
      },
      (r) {
        voidCallBack(r);
        Loader.dismiss();
      },
    );
  }

  // Get Single Category
  Future<void> getCategoryData({
    required CategoryEntity category,
    required Function(CategoryEntity?) voidCallBack,
  }) async {
    GetCategoryUseCase getCategoryUseCase = initController(
      () => GetCategoryUseCase(Get.find()),
    );

    final Either<AppError, CategoryEntity> result = await getCategoryUseCase
        .call(category);

    result.fold((l) => Loader.showError(l.messege), (r) {
      voidCallBack(r);
      Loader.dismiss();
    });
  }
}
