// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class FirebaseRepoImpl extends FirebaseRepository {
  final Firebase_DataSourceRepo _firebaseRemote_DataSourceImpl;

  FirebaseRepoImpl(this._firebaseRemote_DataSourceImpl);

  @override
  Future<Either<AppError, UserCredential>> loginDomain_firebase(
    FirebaseAuthModel firebaseAuthModel,
  ) async {
    final result = await _firebaseRemote_DataSourceImpl.login_firebase(
      firebaseAuthModel,
    );

    return result is Success<UserCredential>
        ? right(result.data)
        : left(AppError((result as Failure).errorHandler.message ?? ""));
  }

  @override
  Future<Either<AppError, UserCredential>> signupDomain_firebase(
    FirebaseAuthModel firebaseAuthModel,
  ) async {
    final result = await _firebaseRemote_DataSourceImpl.signup_firebase(
      firebaseAuthModel,
    );
    return result is Success<UserCredential>
        ? right(result.data)
        : left(AppError((result as Failure).errorHandler.message ?? ""));
  }

  @override
  Future<Either<AppError, String>> uploadImage_firebase(
    String key,
    File image,
  ) async {
    final result = await _firebaseRemote_DataSourceImpl.uploadImage_firebase(
      key,
      image,
    );

    return result is Success<String>
        ? right(result.data)
        : left(AppError((result as Failure).errorHandler.message ?? ""));
  }
}
