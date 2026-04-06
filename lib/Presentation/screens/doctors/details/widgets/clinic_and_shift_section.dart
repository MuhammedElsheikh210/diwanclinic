import 'package:diwanclinic/Presentation/Widgets/drop_down/adatper/clinic_adapter.dart';
import 'clinic_info_widget.dart';
import '../../../../../../index/index_main.dart';

class ClinicAndShiftSection extends StatelessWidget {
  final DoctorDetailsViewModel controller;
  final bool? showClinicInfo;
  final bool? showFromHome;

  const ClinicAndShiftSection({
    super.key,
    required this.controller,
    this.showClinicInfo,
    this.showFromHome,

  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    // ✅ Convert lists
    final clinicItems = ModelAdapterUtil.clinicListToGeneric(
      controller.listClinics,
    );
    final shiftItems = ModelAdapterUtil.shiftListToGeneric(
      controller.listShifts,
    );
    final reservationTypeItems = controller.reservationTypes
        .asMap()
        .entries
        .map(
          (entry) =>
              GenericListModel(key: 'type_${entry.key}', name: entry.value),
        )
        .toList();

    // ✅ Current selections
    final selectedClinicValue = controller.selectedClinic != null
        ? ModelAdapterUtil.clinicToGeneric(controller.selectedClinic)
        : null;

    final selectedShiftValue = controller.selectedShift != null
        ? ModelAdapterUtil.shiftToGeneric(controller.selectedShift)
        : null;

    final selectedTypeValue = controller.selectedReservationType != null
        ? GenericListModel(
            key: controller.selectedReservationType!,
            name: controller.selectedReservationType!,
          )
        : null;

    // 🔹 Calculate deposit dynamically
    double selectedPrice = 0.0;
    final clinic = controller.selectedClinic;
    final depositPercent = clinic?.minimumDepositPercent ?? 0.0;
    double depositAmount = 0.0;

    if (clinic != null) {
      switch (controller.selectedReservationType) {
        case "كشف مستعجل":
          selectedPrice =
              double.tryParse(clinic.urgentConsultationPrice ?? "0") ?? 0.0;
          break;
        case "إعادة":
          selectedPrice = double.tryParse(clinic.followUpPrice ?? "0") ?? 0.0;
          break;
        default:
          selectedPrice =
              double.tryParse(clinic.consultationPrice ?? "0") ?? 0.0;
          break;
      }
      depositAmount = (selectedPrice * depositPercent) / 100;
    }

    // ✅ Detect if there is only one clinic
    final hasSingleClinic =
        controller.listClinics != null && controller.listClinics!.length == 1;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15.h,
        horizontal: showClinicInfo == false ? 0.w : 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowUpper.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏥 Clinic Dropdown (only if > 1 clinic)
          if (!hasSingleClinic)
            GenericDropdown<GenericListModel>(
              hint_text: "اختر العيادة",
              title: "العيادة",
              items: clinicItems,
              initialValue: selectedClinicValue,
              onChanged: (val) {
                final selected = ModelAdapterUtil.findClinicByGeneric(
                  controller.listClinics,
                  val,
                );
                if (selected != null) controller.onSelectClinic(selected);
              },
              displayItemBuilder: (item) => Text(
                item.name ?? "",
                style: typography.mdRegular.copyWith(
                  color: ColorMappingImpl().textLabel,
                ),
              ),
            ),

          if (controller.selectedClinic != null) ...[
            if (!hasSingleClinic) SizedBox(height: 10.h),

            // 🔹 Clinic Info (always show)
            showClinicInfo == false
                ? const SizedBox()
                : Padding(
                    padding: EdgeInsets.only(bottom: 16.0.h),
                    child: ClinicInfoWidget(clinic: controller.selectedClinic!),
                  ),

        showFromHome == true ?   Column(children: [
             // 🔹 Shift Dropdown
             GenericDropdown<GenericListModel>(
               hint_text: "اختر الشفت",
               title: "اختر الشفت",
               items: shiftItems,
               initialValue: selectedShiftValue,
               onChanged: (val) {
                 final selected = ModelAdapterUtil.findShiftByGeneric(
                   controller.listShifts,
                   val,
                 );
                 controller.selectedShift = selected;
                 controller.update();
               },
               displayItemBuilder: (item) => Text(
                 item.name ?? "",
                 style: typography.mdRegular.copyWith(
                   color: ColorMappingImpl().textLabel,
                 ),
               ),
             ),

             const SizedBox(height: 15),

             // 🔹 Reservation Type Dropdown
             GenericDropdown<GenericListModel>(
               hint_text: "اختر نوع الحجز",
               title: "نوع الحجز",
               items: reservationTypeItems,
               initialValue: selectedTypeValue,
               onChanged: (val) {
                 controller.onSelectReservationType(val.name ?? "");
               },
               displayItemBuilder: (item) => Text(
                 item.name ?? "",
                 style: typography.mdRegular.copyWith(
                   color: ColorMappingImpl().textLabel,
                 ),
               ),
             ),

             // 🔹 Urgent Policy Info
             if (controller.selectedReservationType == "كشف مستعجل" &&
                 controller.selectedClinic?.urgentPolicy != null)
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: Text(
                   "⚠️ سياسة الكشف المستعجل: سيُنتظر ${controller.selectedClinic?.urgentPolicy} كشف عادي قبل الدخول",
                   style: context.typography.smRegular.copyWith(
                     color: AppColors.tag_icon_warning,
                   ),
                 ),
               ),
           ],) : const SizedBox()
          ],
        ],
      ),
    );
  }
}
