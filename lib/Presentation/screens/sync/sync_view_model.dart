import '../../../index/index_main.dart';

class SyncViewModel extends GetxController {
  final ParentSyncService parentSyncService = Get.put(ParentSyncService());
  RxDouble progress = 0.0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    parentSyncService.progress.listen((value) {
      progress.value = value;

      // When progress completes
      if (value >= 1.0) {
        Future.delayed(const Duration(seconds: 1), () {
          // Example: navigate or show success message
          print("done");
          //  Get.snackbar("Sync Completed", "All data synced successfully!");
        });
      }
    });

    await parentSyncService.syncAllData(
      voidCallBack: (data) {
        print("data is $data");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => const MainPage(), binding: Binding());
        });
      },
    );
  }
}
