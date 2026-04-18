import '../../../index/index_main.dart';
import 'sync_medicine_service.dart';

class SyncMedicineViewModel extends GetxController {
  late final SyncMedicineService service;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    service = Get.find<SyncMedicineService>();
    _start();
  }

  Future<void> _start() async {
    try {
      

      await service.prepareDatabase();
      await service.openDatabaseInstance();

      

      Get.offAll(() => const MainPage(), binding: Binding());
    } catch (e, s) {
      
      debugPrintStack(stackTrace: s);

      Get.snackbar("خطأ", "فشل تجهيز قاعدة بيانات الأدوية");
    }
  }
}

class SyncMedicineBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SyncMedicineService());
    Get.put(SyncMedicineViewModel());
  }
}
