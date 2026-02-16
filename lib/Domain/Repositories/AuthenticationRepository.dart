// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class AuthenticationRepository {
  // ───── Clients ─────

  /// 🔹 Get all clients (remote)
  Future<Either<AppError, List<LocalUser?>>> getClients_domain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔹 Get all clients (local)
  Future<Either<AppError, List<LocalUser?>>> getClientsLocal_domain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔹 Get single client
  Future<Either<AppError, LocalUser?>> getClientIndividual_domain(
      Map<String, dynamic> data,
      );


  /// 🔹 Add new client
  Future<Either<AppError, SuccessModel>> addClient_domain(
      Map<String, dynamic> data,
      String key,
      );

  /// 🔹 Delete client
  Future<Either<AppError, SuccessModel>> deleteClient_domain(
      Map<String, dynamic> data,
      String key,
      );

  /// 🔹 Update client
  Future<Either<AppError, SuccessModel>> updateClient_domain(
      Map<String, dynamic> data,
      String key,
      );
}
