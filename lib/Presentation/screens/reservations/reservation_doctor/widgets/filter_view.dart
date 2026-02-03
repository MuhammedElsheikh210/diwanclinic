import '../../../../../index/index_main.dart';
import 'package:diwanclinic/Presentation/Widgets/drop_down/adatper/clinic_adapter.dart';

class FilterViewReservation extends StatefulWidget {
  const FilterViewReservation({Key? key}) : super(key: key);

  @override
  State<FilterViewReservation> createState() => _FilterViewReservationState();
}

class _FilterViewReservationState extends State<FilterViewReservation> {
  GenericListModel? selectedClinic;
  List<GenericListModel>? clinicDropdownItems;

  final ReservationDoctorViewModel controller =
      Get.find<ReservationDoctorViewModel>();

  @override
  void initState() {
    super.initState();
    _loadClinicsLocal();

    /// Pre-fill selected clinic
    if (controller.selectedClinic != null) {
      selectedClinic = GenericListModel(
        key: controller.selectedClinic!.key,
        name: controller.selectedClinic!.title,
      );
    }
  }

  // ---------------------------------------------------------------------
  // 🔹 Load Clinics Locally (only clinics belonging to doctor)
  // ---------------------------------------------------------------------
  void _loadClinicsLocal() {
    final doctorKey = LocalUser().getUserData().doctorKey ?? "";

    ClinicService().getClinicsData(
      data: {},
      filrebaseFilter: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: doctorKey.isNotEmpty,
        where: doctorKey.isNotEmpty ? "doctor_key = ?" : null,
        whereArgs: doctorKey.isNotEmpty ? [doctorKey] : null,
      ),
      voidCallBack: (data) {
        Loader.dismiss();
        clinicDropdownItems = ClinicAdapterUtil.convertClinicListToGeneric(
          data,
        );
        setState(() {});
      },
    );
  }

  // ---------------------------------------------------------------------
  // 🔹 Apply Filters — ONLY clinic now
  // ---------------------------------------------------------------------
  void applyFilters() {
    controller.selectedClinic = null;

    if (selectedClinic != null) {
      controller.selectedClinic = ClinicModel(
        key: selectedClinic!.key,
        title: selectedClinic!.name,
      );
    }

    controller.getReservations(is_filter: true);
    controller.update();
    Get.back();
  }

  // ---------------------------------------------------------------------
  // 🔹 Reset Filters
  // ---------------------------------------------------------------------
  void resetFilters() {
    setState(() {
      selectedClinic = null;
    });

    controller.selectedClinic = null;
    controller.getReservations();
    controller.update();

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                SizedBox(height: 15.h),
                Center(
                  child: Text(
                    "فلترة العيادات",
                    style: context.typography.lgBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: 25.h),

                // ---------------------------------------------------------------------
                // 🔹 Clinic Dropdown ONLY
                // ---------------------------------------------------------------------
                Text(
                  "العيادة",
                  style: context.typography.mdMedium.copyWith(
                    color: AppColors.text_primary_paragraph,
                  ),
                ),
                SizedBox(height: 8.h),

                clinicDropdownItems == null
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : GenericDropdown<GenericListModel>(
                        hint_text: "اختر العيادة",
                        title: "اختر العيادة",
                        show_title: false,
                        items: clinicDropdownItems!,
                        initialValue: selectedClinic,
                        onChanged: (v) => setState(() => selectedClinic = v),
                        displayItemBuilder: (item) => Text(
                          item.name ?? "",
                          style: context.typography.smRegular.copyWith(
                            color: AppColors.secondary100,
                          ),
                        ),
                      ),

                SizedBox(height: 30.h),

                // ---------------------------------------------------------------------
                // 🔹 Buttons
                // ---------------------------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: PrimaryTextButton(
                        onTap: applyFilters,
                        label: AppText(
                          text: "تطبيق الفلتر",
                          textStyle: context.typography.mdBold.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        customBackgroundColor: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: resetFilters,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          "مسح الفلتر",
                          style: context.typography.mdMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
