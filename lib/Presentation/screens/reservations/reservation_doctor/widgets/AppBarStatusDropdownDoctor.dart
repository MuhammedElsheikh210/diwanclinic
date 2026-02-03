import 'package:diwanclinic/Global/Enums/reservation_status_new.dart';

import '../../../../../index/index_main.dart';

class AppBarStatusDropdownDoctor extends StatefulWidget {
  final ReservationDoctorViewModel controller;

  const AppBarStatusDropdownDoctor({super.key, required this.controller});

  @override
  State<AppBarStatusDropdownDoctor> createState() =>
      _AppBarStatusDropdownDoctorState();
}

class _AppBarStatusDropdownDoctorState
    extends State<AppBarStatusDropdownDoctor> {
  final key = GlobalKey();
  OverlayEntry? _overlay;

  GenericListModel? selected =
  GenericListModel(key: "all", name: "في الكشف + انتظار");

  @override
  void initState() {
    super.initState();

    widget.controller.selectedStatus = null;
    widget.controller.selectedStatusesList = [
      ReservationNewStatus.approved,
      ReservationNewStatus.inProgress,
      ReservationNewStatus.pending,
    ];
  }

  void _toggle() => _overlay == null ? _open() : _close();

  void _open() {
    final box = key.currentContext!.findRenderObject() as RenderBox;
    final size = box.size;
    final offset = box.localToGlobal(Offset.zero);

    final items = [
      GenericListModel(key: "all_statuses", name: "الكــــل"),
      GenericListModel(key: "all", name: "في الكشف + انتظار"),
      ...ReservationNewStatus.values.map(
            (s) => GenericListModel(key: s.value, name: s.label),
      ),
    ];

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: _close,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: offset.dy + size.height + 8,
            left: offset.dx,
            width: size.width,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              elevation: 3,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: items.map(_buildItem).toList(),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  Widget _buildItem(GenericListModel item) {
    return ListTile(
      title: Text(item.name!, style: context.typography.smMedium),
      trailing: selected?.key == item.key
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => selected = item);

        if (item.key == "all_statuses") {
          widget.controller.selectedStatus = null;
          widget.controller.selectedStatusesList = null;
        } else if (item.key == "all") {
          widget.controller.selectedStatus = null;
          widget.controller.selectedStatusesList = [
            ReservationNewStatus.approved,
            ReservationNewStatus.inProgress,
            ReservationNewStatus.pending,
          ];
        } else {
          widget.controller.selectedStatusesList = null;
          widget.controller.selectedStatus =
              ReservationStatusNewExt.fromValue(item.key!);
        }

        widget.controller.getReservations(is_filter: false);
        widget.controller.update();

        _close();
      },
    );
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: key,
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.grayLight.withOpacity(0.4),
            width: 2,
          ),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(selected?.name ?? "الحالة",
                style: context.typography.mdBold),
            const Icon(Icons.expand_more, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
