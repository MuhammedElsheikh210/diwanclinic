import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class TransactionService {
  // Add Transaction
  Future<void> addTransactionData({
    required TransactionsEntity transaction,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final addTransactionUseCase = initController(
      () => AddTransactionUseCase(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await addTransactionUseCase
        .call(transaction);

    result.fold((l) {
      print("error message is ${l.messege}");
      return Loader.showError(l.messege);
    }, (r) => voidCallBack(ResponseStatus.success));

    Loader.dismiss();
  }

  // Update Transaction
  Future<void> updateTransactionData({
    required TransactionsEntity transaction,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final updateTransactionUseCase = initController(
      () => UpdateTransactionUseCase(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await updateTransactionUseCase
        .call(transaction);

    result.fold(
      (l) => Loader.showError(l.messege),
      (r) => voidCallBack(ResponseStatus.success),
    );

    Loader.dismiss();
  }

  // Delete Transaction
  Future<void> deleteTransactionData({
    required String transactionKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final deleteTransactionUseCase = initController(
      () => DeleteTransactionUseCase(Get.find()),
    );

    final Either<AppError, SuccessModel> result = await deleteTransactionUseCase
        .call(transactionKey);

    result.fold(
      (l) => Loader.showError(l.messege),
      (r) => voidCallBack(ResponseStatus.success),
    );

    Loader.dismiss();
  }

  // Get All Transactions
  Future<void> getAllTransactionsData({
    required Function(List<TransactionsEntity?>) voidCallBack,
    required SQLiteQueryParams? filter,
  }) async {
    //  Loader.show();
    final getAllTransactionsUseCase = initController(
      () => GetAllTransactionsUseCase(Get.find()),
    );

    final Either<AppError, List<TransactionsEntity?>> result =
        await getAllTransactionsUseCase.call(filter ?? SQLiteQueryParams());

    result.fold((l) => Loader.showError(l.messege), (r) {
      voidCallBack(r);
      Loader.dismiss();
    });
  }
}
