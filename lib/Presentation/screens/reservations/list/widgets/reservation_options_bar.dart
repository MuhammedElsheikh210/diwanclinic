import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view.dart';
import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view_model.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/widgets/reserbation_status_type_appbar.dart';
import 'package:diwanclinic/index/index_main.dart';

class ReservationViewOptionsBar extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onToggleView;
  final ReservationViewModel controller;

  const ReservationViewOptionsBar({
    super.key,
    required this.isGrid,
    required this.onToggleView,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grayLight, width: 1),
      ),
      child: Row(
        children: [
          // 🔽 Status Dropdown
          Expanded(child: AppBarStatusDropdown(controller: controller)),

          const SizedBox(width: 12),
          // ⭐ زر البحث الجديد
          GestureDetector(
            onTap: () => _openSearchSheet(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 🔄 View Toggle Button (List <-> Grid)
          _ViewToggleButton(isGrid: isGrid, onToggleView: onToggleView),
        ],
      ),
    );
  }

  void _openSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => _PatientSearchSheet(controller),
    );
  }
}

// -----------------------------------------------------
// 🔘 CUSTOM VIEW TOGGLE BUTTON
// -----------------------------------------------------
class _ViewToggleButton extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onToggleView;

  const _ViewToggleButton({required this.isGrid, required this.onToggleView});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleView,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isGrid ? Icons.grid_view_rounded : Icons.list_alt_rounded,
          size: 28,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _PatientSearchSheet extends StatefulWidget {
  const _PatientSearchSheet(this.controller);

  final ReservationViewModel controller;

  @override
  State<_PatientSearchSheet> createState() => _PatientSearchSheetState();
}

class _PatientSearchSheetState extends State<_PatientSearchSheet> {
  final vm = Get.put(PatientSearchViewModel(), tag: "dropdown_search");

  final FocusNode searchFocus = FocusNode();
  bool showResults = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag bar
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            /// 🔍 Search bar
            PatientSearchBar(
              tag: "dropdown_search",
              hint: "ابحث بالاسم / رقم الهاتف / رقم الملف",
              textEditingController: vm.textEditingController,
              textInputType: TextInputType.text,
              focusNode: searchFocus,
              searchResult: (_, text) {
                setState(() {
                  showResults = text.isNotEmpty;
                });
              },
            ),

            const SizedBox(height: 10),

            /// 📋 Results list
            if (showResults)
              SizedBox(
                height: 300,
                child: PatientResultList(
                  tag: "dropdown_search",
                  onSelect: (patient) async {
                    // Navigator.pop(context);

                    // ✔ تحميل آخر زيارة
                    await widget.controller.getLastReservationDateForPatient(
                      patient,
                    );
                    setState(() {}); // 🔥 مهم جدًا
                  },
                ),
              ),

            widget.controller.selectedPatientLastVisit != null
                ? Text(
                    widget.controller.selectedPatientLastVisit.toString(),
                    style: context.typography.lgBold.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : const SizedBox(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
