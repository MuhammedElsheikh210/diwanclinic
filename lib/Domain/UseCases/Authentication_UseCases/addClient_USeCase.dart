// ignore_for_file: avoid_renaming_method_parameters

import 'package:dartz/dartz.dart';

import '../../../index/index_main.dart';


class AddClientUseCase
    extends Use_Case<Either<AppError, SuccessModel>, LocalUser> {
  final AuthenticationRepository _authenticationRepository;

  AddClientUseCase(this._authenticationRepository);

  @override
  Future<Either<AppError, SuccessModel>> call(LocalUser userclient) async {
    Either<AppError, SuccessModel> data = await _authenticationRepository
        .addClient_domain(userclient.toJson(), userclient.key ?? "");
    return data;
  }
}
