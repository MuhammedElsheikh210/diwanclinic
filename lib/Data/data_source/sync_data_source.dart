import '../../index/index_main.dart';

abstract class SyncDataSourceRepo {
  Future<ApiResult<SyncModel?>> getSync(Map<String, dynamic> data,bool? online);

  Future<ApiResult<SuccessModel>> addSync(
    Map<String, dynamic> data,
    String key,
  );

  Future<ApiResult<SuccessModel>> updateSync(
    Map<String, dynamic> data,
    String key,
  );

  Future<ApiResult<SuccessModel>> deleteSync(
    Map<String, dynamic> data,
    String key,
  );
}
