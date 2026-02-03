// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:io';
import '../../index/index_main.dart';

abstract class Firebase_DataSourceRepo {
  Future<ApiResult<UserCredential>> login_firebase(
    FirebaseAuthModel firebaseAuthModel,
  );

  Future<ApiResult<UserCredential>> signup_firebase(
    FirebaseAuthModel firebaseAuthModel,
  );

  Future<ApiResult<String>> uploadImage_firebase(String key, File image);
}
