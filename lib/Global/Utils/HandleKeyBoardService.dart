import 'dart:math';

import '../../../index/index_main.dart';

class HandleKeyBoardService extends GetxController {
  late List<FocusNode> focusNodes;

  // Singleton pattern for easy access
  static HandleKeyBoardService get to =>
      Get.put<HandleKeyBoardService>(HandleKeyBoardService());

  HandleKeyBoardService();

  @override
  void onInit() {
    super.onInit();

    // Initialize a list of focus nodes
    focusNodes = List.generate(100000, (_) => FocusNode());
  }

  @override
  void onClose() {
    // // Dispose all focus nodes
    // for (var node in focusNodes) {
    //   node.dispose();
    // }
    super.onClose();
  }

  KeyboardActionsConfig buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      defaultDoneWidget: Text(
         "تم".tr,
       style: context.typography.mdBold,
      ),
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[300],
      nextFocus: true,
      actions: focusNodes
          .map((node) => KeyboardActionsItem(focusNode: node))
          .toList(),
    );
  }
}

int getFiveDigitRandomKey() {
  final random = Random();
  // This returns a number from 10000 to 99999 (inclusive)
  return random.nextInt(90000) + 10000;
}
