// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class FirebaseRepository {
  Future<Either<AppError, UserCredential>> loginDomain_firebase(
    FirebaseAuthModel firebaseAuthModel,
  );

  Future<Either<AppError, UserCredential>> signupDomain_firebase(
    FirebaseAuthModel firebaseAuthModel,
  );

  Future<Either<AppError, String>> uploadImage_firebase(String key, File image);
}
