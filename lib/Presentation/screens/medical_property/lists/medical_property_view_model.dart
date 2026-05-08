import '../../../../../index/index_main.dart';

class MedicalPropertyViewModel extends GetxController {
  /// ✅ Dynamic category type
  final String? categoryType;

  /// ✅ Current selected category
  final CategoryEntity? categoryEntity;

  MedicalPropertyViewModel({this.categoryType, this.categoryEntity});

  List<MedicalRecordPropertyModel?>? listProperties;

  @override
  Future<void> onInit() async {
    getData();

    super.onInit();
  }

  /// ✅ Fetch Properties
  void getData() {
    MedicalRecordPropertyService().getMedicalRecordPropertiesData(
      data: {},

      firebaseFilter: FirebaseFilter(
        orderBy: "category_key",
        equalTo: categoryEntity?.key,
      ),

      query: SQLiteQueryParams(),

      voidCallBack: (data) {
        listProperties = data;

        update();
      },
    );
  }

  /// ✅ Delete Property
  void deleteProperty(MedicalRecordPropertyModel property) {
    MedicalRecordPropertyService().deleteMedicalRecordPropertyData(
      propertyKey: property.key ?? "",

      voidCallBack: (_) {
        getData();
      },
    );
  }
}
