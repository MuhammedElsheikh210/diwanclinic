import 'dart:io';

import 'package:image_picker/image_picker.dart';

class PickedImage {
  File? _image;
  XFile? pickedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage({required Function(File?) callBack}) async {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile?.path ?? "");
      callBack(_image);
    }
  }
}
