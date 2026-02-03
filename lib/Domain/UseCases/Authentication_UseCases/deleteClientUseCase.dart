// ignore_for_file: avoid_renaming_method_parameters

import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class DeleteClientUseCase
    extends Use_Case<Either<AppError, SuccessModel>, String> {
  final AuthenticationRepository _authenticationRepository;

  DeleteClientUseCase(this._authenticationRepository);

  @override
  Future<Either<AppError, SuccessModel>> call(String url) async {
    return await _authenticationRepository.deleteClient_domain({}, url);
  }
}
