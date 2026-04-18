// import '../../index/index_main.dart';
//
// class SyncRemoteDataSourceImpl extends SyncDataSourceRepo {
//   final ClientSourceRepo _clientSourceRepo;
//   final BaseSQLiteDataSourceRepo<SyncModel> _sqliteRepo;
//
//   SyncRemoteDataSourceImpl(this._clientSourceRepo)
//     : _sqliteRepo = BaseSQLiteDataSourceRepo<SyncModel>(
//         tableName: "sync",
//         fromJson: (json) => SyncModel.fromJson(json),
//         toJson: (model) => model.toJson(),
//         getId: (model) => LocalUser().getUserData().uid,
//       );
//
//   /// ✅ Get a single SyncModel from SQLite or fallback to remote
//   @override
//   Future<ApiResult<SyncModel?>> getSync(
//     Map<String, dynamic> data,
//     bool? online,
//   ) async {
//     
//     try {
//       if (online != true) {
//         final String key = LocalUser().getUserData().uid ?? "";
//         final localItem = await _sqliteRepo.getItem(key);
//         
//         if (localItem != null) return Success(localItem);
//       }
//     } catch (_) {}
//
//     try {
//       final String key = LocalUser().getUserData().uid ?? "";
//       final response = await _clientSourceRepo.request(
//         HttpMethod.GET,
//         "/${ApiConstatns.organization}/$key.json",
//       );
//       if (response == null) return const Success(null);
//       final modelJson = Map<String, dynamic>.from(response);
//       modelJson['key'] = key;
//       final syncModel = SyncModel.fromJson(modelJson);
//       await _sqliteRepo.addItem(syncModel);
//
//       return Success(syncModel);
//     } catch (error) {
//       return Failure(ErrorHandler.handle(error));
//     }
//   }
//
//   /// ✅ Add Sync to SQLite + Firebase
//   @override
//   Future<ApiResult<SuccessModel>> addSync(
//     Map<String, dynamic> data,
//     String key,
//   ) async {
//     try {
//       final syncModel = SyncModel.fromJson(data);
//       await _sqliteRepo.addItem(syncModel);
//
//       final response = await _clientSourceRepo.request(
//         HttpMethod.PATCH,
//         "/${ApiConstatns.organization}/$key.json",
//         params: data,
//       );
//
//       return Success(SuccessModel.fromJson(response));
//     } catch (error) {
//       return Failure(ErrorHandler.handle(error));
//     }
//   }
//
//   /// ✅ Update Sync in SQLite + Firebase
//   @override
//   Future<ApiResult<SuccessModel>> updateSync(
//     Map<String, dynamic> data,
//     String key,
//   ) async {
//     try {
//       final syncModel = SyncModel.fromJson(data);
//       await _sqliteRepo.updateItem(syncModel);
//
//       final response = await _clientSourceRepo.request(
//         HttpMethod.PATCH,
//         "/${ApiConstatns.organization}/$key.json",
//         params: data,
//       );
//
//       return Success(SuccessModel.fromJson(response));
//     } catch (error) {
//       return Failure(ErrorHandler.handle(error));
//     }
//   }
//
//   /// ✅ Delete Sync from SQLite + Firebase
//   @override
//   Future<ApiResult<SuccessModel>> deleteSync(
//     Map<String, dynamic> data,
//     String key,
//   ) async {
//     try {
//       await _sqliteRepo.deleteItem(key);
//
//       final response = await _clientSourceRepo.request(
//         HttpMethod.DELETE,
//         "/${ApiConstatns.organization}/$key.json",
//         params: data,
//       );
//
//       final model =
//           response == null
//               ? SuccessModel(message: Strings.delete_message.tr)
//               : SuccessModel.fromJson(response);
//
//       return Success(model);
//     } catch (error) {
//       return Failure(ErrorHandler.handle(error));
//     }
//   }
// }
