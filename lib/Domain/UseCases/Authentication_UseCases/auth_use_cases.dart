// ignore_for_file: avoid_renaming_method_parameters

import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class AuthenticationUseCases {
  final AuthenticationRepository _repository;

  AuthenticationUseCases(this._repository);

  Future<Either<AppError, SuccessModel>> addClient(LocalUser client) {
    return _repository.addClient_domain(client.toJson(), client.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> updateClient(LocalUser client) {
    return _repository.updateClient_domain(client.toJson(), client.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> deleteClient(String key) {
    return _repository.deleteClient_domain({}, key);
  }

  Future<Either<AppError, List<LocalUser?>>> getClients({
    Map<String, dynamic> data = const {},
    SQLiteQueryParams? query,
    bool? isFiltered,
  }) {
    return _repository.getClients_domain(
      data,
      query ?? SQLiteQueryParams(),
      isFiltered,
    );
  }

  Future<Either<AppError, List<LocalUser?>>> getClientsLocal({
    Map<String, dynamic> data = const {},
    SQLiteQueryParams? query,
    bool? isFiltered,
  }) {
    return _repository.getClientsLocal_domain(
      data,
      query ?? SQLiteQueryParams(),
      isFiltered,
    );
  }

  Future<Either<AppError, LocalUser?>> getClientIndividual(
    Map<String, dynamic> data,
  ) {
    return _repository.getClientIndividual_domain(data);
  }
}
