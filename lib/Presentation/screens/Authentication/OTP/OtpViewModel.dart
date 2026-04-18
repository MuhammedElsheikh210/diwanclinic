// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously




import '../../../../index/index_main.dart';

class OtpViewModel extends GetxController {
  String code = "";
  String? phoneValue;
  var isvalidate = "".obs;
  bool? isFill;
  var SCount = 60;
  var isTimerEnded = false;
  late Timer _timer;
  late FocusNode myFocusNode;
  late FocusNode myFocusNode2;
  late FocusNode myFocusNode3;
  late FocusNode myFocusNode4;

  OtpViewModel();

  resendOTP() async {
    StateTimerStart();
  }

  bool isValiedate() {
    if (isvalidate.value.length != 4) {
      return false;
    }
    return true;
  }

  @override
  Future<void> onInit() async {
    myFocusNode = FocusNode();
    myFocusNode2 = FocusNode();
    myFocusNode3 = FocusNode();
    myFocusNode4 = FocusNode();
    var data = await Get.arguments;
    String phone = data["phone"] as String;
    phoneValue = phone;
    StateTimerStart();
    update();
    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    myFocusNode.dispose();
    myFocusNode2.dispose();
    myFocusNode3.dispose();
    myFocusNode4.dispose();
  }


  Color codeViewBorderColor() {
    if (code.isEmpty) {
      
      return ColorResources.COLOR_GREY70;
    } else if (code.isNotEmpty && isFill == false) {
      
      return ColorResources.COLOR_red;
    } else {
      
      return ColorResources.COLOR_Primary;
    }
  }

  void StateTimerStart() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (SCount > 0) {
        SCount--;
        update();
      } else {
        isTimerEnded = true;
        _timer.cancel();
        update();
      }
    });
  }

  // pause the timer
  void Pause() {
    _timer.cancel();
    update();
  }

  Future<void> resendOtpAction() async {
    reset();
  }

  // reset count value to 10
  void cancelTimer() {
    _timer.cancel();
    SCount = 0;
    isTimerEnded = true;
    update();
  }

  // reset count value to 10
  void reset() {
    _timer.cancel();
    SCount = 60;
    StateTimerStart();
    isTimerEnded = false;
    update();
  }

  Future<void> otpData() async {
    // Loader.show();
    // AuthRequestParams authRequestParams = AuthRequestParams(
    //     code: code,
    //     identifier: phoneValue,
    //     platform: ConstantsData.deviceType(),
    //     fcm_token: await ConstantsData.firebaseToken());
    // final Either<AppError, UserData> userdata =
    //     await LoginUseCase.to(authRequestParams);
    //
    // userdata.fold((l) {
    //   Loader.showError(l.messege ?? "");
    //   isFill = false;
    //
    //
    //   update();
    // }, (r) async {
    //   Loader.showSuccess(r.message ?? "");
    //   NavigationGet().route_name(successfullyVerificationView);
    //   update();
    // });
  }
}
