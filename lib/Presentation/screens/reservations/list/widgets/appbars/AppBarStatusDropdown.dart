import '../../../../../../index/index_main.dart';

class AppBarTypeDropdown extends StatefulWidget {
  final ReservationViewModel controller;

  const AppBarTypeDropdown({Key? key, required this.controller})
    : super(key: key);

  @override
  State<AppBarTypeDropdown> createState() => _AppBarTypeDropdownState();
}

class _AppBarTypeDropdownState extends State<AppBarTypeDropdown> {
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  GenericListModel? selected;

  @override
  void initState() {
    super.initState();

    // Set default → "الكل"
    selected = GenericListModel(key: "all", name: "كل الكشوفات");
  }

  // -------------------------------------------------------------
  // Toggle dropdown
  // -------------------------------------------------------------
  void _toggle() {
    if (_overlayEntry == null) {
      _open();
    } else {
      _close();
    }
  }

  // -------------------------------------------------------------
  // Open dropdown
  // -------------------------------------------------------------
  void _open() {
    final renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final List<GenericListModel> items = [
      GenericListModel(key: "all", name: "كل الكشوفات"),
      ...widget.controller.reservationTypeFilters.map(
        (t) => GenericListModel(key: t, name: t),
      ),
    ];

    _overlayEntry = OverlayEntry(
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
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: items.map((item) {
                    return ListTile(
                      title: Text(
                        item.name ?? "",
                        style:  context.typography.smMedium,
                      ),
                      trailing: (selected?.key == item.key)
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() => selected = item);

                         // ---------------------------------------------
                        // Apply filter
                        // ---------------------------------------------
                        if (item.key == "all") {
                          widget.controller.selectedType = null;
                        } else {
                          widget.controller.selectedType = item.key;
                        }

                     //   widget.controller.getReservations(isFilter: false);
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

  // -------------------------------------------------------------
  // Close dropdown
  // -------------------------------------------------------------
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
            Text(
              selected?.name ?? "كل الكشوفات",
              style: context.typography.lgBold.copyWith(),
            ),
            const SizedBox(width: 10),
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
