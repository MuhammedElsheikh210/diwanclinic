import '../../index/index_main.dart';

abstract class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final ApiErrorModel errorHandler;

  const Failure(this.errorHandler);
}
