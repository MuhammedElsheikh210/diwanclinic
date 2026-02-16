// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class AuthenticationRepoImpl extends AuthenticationRepository {
  final AuthenticationDataSourceRepo _authenticationRemoteDataSourceImpl;

  AuthenticationRepoImpl(this._authenticationRemoteDataSourceImpl);

  @override
  Future<Either<AppError, SuccessModel>> addClient_domain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _authenticationRemoteDataSourceImpl.addClient(
        data,
        key,
      );
      return right(result);
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteClient_domain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _authenticationRemoteDataSourceImpl.deleteClient(
        data,
        key,
      );
      return right(result);
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateClient_domain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _authenticationRemoteDataSourceImpl.updateClient(
        data,
        key,
      );
      return right(result);
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, LocalUser?>> getClientIndividual_domain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _authenticationRemoteDataSourceImpl
          .getClient_Individual(data);
      return right(result);
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, List<LocalUser?>>> getClients_domain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final result = await _authenticationRemoteDataSourceImpl.getClients(
        data,
        query,
        isFiltered,
      );
      return right(result);
    } catch (e) {
      try {
        final localResult = await _authenticationRemoteDataSourceImpl
            .getClients_local(data, query, isFiltered);
        return right(localResult);
      } catch (localError) {
        return left(AppError(localError.toString()));
      }
    }
  }

  @override
  Future<Either<AppError, List<LocalUser?>>> getClientsLocal_domain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final result = await _authenticationRemoteDataSourceImpl.getClients_local(
        data,
        query,
        isFiltered,
      );
      return right(result);
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }


}
