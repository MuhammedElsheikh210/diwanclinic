// ignore_for_file: avoid_renaming_method_parameters, camel_case_types

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class FirebaseUploadImage_UseCase extends UseCase<String, FirebaseAuthModel> {
  final FirebaseRepository _firebaseRepository;

  FirebaseUploadImage_UseCase(this._firebaseRepository);

  @override
  Future<Either<AppError, String>> call(FirebaseAuthModel param) async {
    return await _firebaseRepository.uploadImage_firebase(
      "param.key",
      File(""),
    );
  }
}
