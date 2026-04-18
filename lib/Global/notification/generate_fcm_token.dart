import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';

import '../Constatnts/TextConstants.dart';

void main() async {
  final jsonData = json.decode(
    await File('assets/config/${Strings.file_name}.json').readAsString(),
  );
  final credentials = ServiceAccountCredentials.fromJson(jsonData);
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final client = await clientViaServiceAccount(credentials, scopes);
  
  client.close();
}
