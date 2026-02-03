import '../../../../../index/index_main.dart';

class AppBarTypeDropdownDoctor extends StatefulWidget {
  final ReservationDoctorViewModel controller;

  const AppBarTypeDropdownDoctor({super.key, required this.controller});

  @override
  State<AppBarTypeDropdownDoctor> createState() =>
      _AppBarTypeDropdownDoctorState();
}

class _AppBarTypeDropdownDoctorState extends State<AppBarTypeDropdownDoctor> {
  final key = GlobalKey();
  OverlayEntry? _overlay;
  GenericListModel? selected = GenericListModel(key: "all", name: "كل الأنواع");

  void _toggle() => _overlay == null ? _open() : _close();

  void _open() {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final types = [
      GenericListModel(key: "all", name: "كل الأنواع"),
      GenericListModel(key: "كشف جديد", name: "كشف جديد"),
      GenericListModel(key: "إعادة", name: "إعادة"),
      GenericListModel(key: "متابعة", name: "متابعة"),
      GenericListModel(key: "كشف مستعجل", name: "كشف مستعجل"),
    ];

    _overlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _close,
            child: Container(
              width: Get.width,
              height: Get.height,
              color: Colors.transparent,
            ),
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
                children: types.map(_buildItem).toList(),
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

        if (item.key == "all") {
          widget.controller.selectedType = null;
        } else {
          widget.controller.selectedType = item.key;
        }

        widget.controller.getSyncReservations();
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
            Text(selected?.name ?? "", style: context.typography.mdBold),
            const Icon(Icons.expand_more, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
