import 'package:diwanclinic/Global/Enums/reservation_status_new.dart';
import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view.dart';
import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view_model.dart';
import '../../../../../index/index_main.dart';

class AppBarStatusDropdown extends StatefulWidget {
  final ReservationViewModel controller;

  const AppBarStatusDropdown({Key? key, required this.controller})
    : super(key: key);

  @override
  State<AppBarStatusDropdown> createState() => _AppBarStatusDropdownState();
}

class _AppBarStatusDropdownState extends State<AppBarStatusDropdown> {
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  GenericListModel? selected;

  @override
  void initState() {
    super.initState();

    /// Default = EXISTING FILTER → (في الكشف + انتظار الكشف)
  //  selected = GenericListModel(key: "all", name: "في الكشف + انتظار الكشف");

    widget.controller.selectedStatus = null;

    widget.controller.selectedStatusesList = [
      ReservationNewStatus.approved,
      ReservationNewStatus.inProgress,
      ReservationNewStatus.pending,
    ];
  }

  void _toggle() {
    if (_overlayEntry == null) {
      _open();
    } else {
      _close();
    }
  }

  void _open() {
    final renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _close,
            child: Container(
              color: Colors.transparent,
              width: Get.width,
              height: Get.height,
            ),
          ),
          Positioned(
            top: offset.dy + size.height + 8,
            left: offset.dx,
            width: size.width,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children:
                      [
                        /// NEW → ALL STATUSES (No filtering at all)
                        GenericListModel(
                          key: "all_statuses",
                          name: "الــكــــل",
                        ),

                        /// Existing default filter
                        GenericListModel(
                          key: "all",
                          name: "في الكشف + انتظار الكشف",
                        ),

                        ...ReservationNewStatus.values.map(
                          (s) => GenericListModel(key: s.value, name: s.label),
                        ),
                      ].map((item) {
                        return ListTile(
                          title: Text(
                            item.name ?? "",
                            style: context.typography.smMedium,
                          ),
                          trailing: (selected?.key == item.key)
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            setState(() => selected = item);

                            // 🔥 NEW CASE → LOAD ALL STATUSES
                            if (item.key == "all_statuses") {
                              widget.controller.selectedStatus = null;
                              widget.controller.selectedStatusesList = null;
                            }
                            // 🔥 Existing filter = approved + inProgress + pending
                            else if (item.key == "all") {
                              widget.controller.selectedStatus = null;
                              widget.controller.selectedStatusesList = [
                                ReservationNewStatus.approved,
                                ReservationNewStatus.inProgress,
                                ReservationNewStatus.pending,
                              ];
                            }
                            // 🔥 Single specific status
                            else {
                              widget.controller.selectedStatusesList = null;
                              widget.controller.selectedStatus =
                                  ReservationStatusNewExt.fromValue(item.key!);
                            }

                            widget.controller.getReservations(is_filter: false);
                            widget.controller.update();
                            _close();
                          },
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _dropdownKey,
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.grayLight.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(selected?.name ?? "الحالة", style: context.typography.mdBold),
            const SizedBox(width: 5),
            const Icon(Icons.expand_more, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }
}
