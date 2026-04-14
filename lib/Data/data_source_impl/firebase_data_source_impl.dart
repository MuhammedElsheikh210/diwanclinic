import 'dart:io';
import '../../index/index_main.dart';

class FirebaseRemote_DataSourceImpl extends Firebase_DataSourceRepo {
  final FirebaseClient _firebaseClient;

  FirebaseRemote_DataSourceImpl(this._firebaseClient);

  @override
  Future<ApiResult<UserCredential>> login_firebase(
    FirebaseAuthModel firebaseAuthModel,
  ) async {
    try {
      final response = await _firebaseClient.signInUser(firebaseAuthModel);

      return Success(response); // Return success result
    } catch (error) {
      final handledError = ErrorHandler.handle(error);
      return Failure(handledError); // Return failure result
    }
  }

  @override
  Future<ApiResult<UserCredential>> signup_firebase(
    FirebaseAuthModel firebaseAuthModel,
  ) async {
    try {
      final response = await _firebaseClient.createUser(firebaseAuthModel);
      return Success(response); // Return success result
    } catch (error) {
      final handledError = ErrorHandler.handle(error);
      return Failure(handledError); // Return failure result
    }
  }

  @override
  Future<ApiResult<String>> uploadImage_firebase(String key, File image) async {
    String logoBrandUrl = "";
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(key);

      UploadTask uploadTask = storageReference.putFile(image);

      // Await the upload completion
      await uploadTask.whenComplete(() async {
        logoBrandUrl = await storageReference.getDownloadURL();
      });
      return Success(logoBrandUrl);
    } catch (error) {
      final handledError = ErrorHandler.handle(error);
      return Failure(handledError); // Return failure result
    }
  }
}
