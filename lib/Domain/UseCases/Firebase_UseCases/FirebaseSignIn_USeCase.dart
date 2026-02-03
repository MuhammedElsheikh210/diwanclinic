// ignore_for_file: avoid_renaming_method_parameters, camel_case_types

import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class FirebaseSignIn_UseCase
    extends UseCase<UserCredential, FirebaseAuthModel> {
  final FirebaseRepository _firebaseRepository;

  FirebaseSignIn_UseCase(this._firebaseRepository);

  @override
  Future<Either<AppError, UserCredential>> call(
      FirebaseAuthModel userParentModel) async {
    return await _firebaseRepository.loginDomain_firebase(userParentModel);
  }
}
