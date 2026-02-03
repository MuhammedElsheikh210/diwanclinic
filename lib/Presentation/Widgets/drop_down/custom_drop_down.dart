import '../../../index/index_main.dart';

class GenericDropdown<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? initialValue;
  final ValueChanged<T> onChanged;
  final double maxHeight;
  final String hint_text;
  final bool? show_title;
  final Widget Function(T) displayItemBuilder;

  const GenericDropdown({
    Key? key,
    required this.title,
    required this.items,
    required this.hint_text,
    this.initialValue,
    this.show_title,
    required this.onChanged,
    required this.displayItemBuilder,
    this.maxHeight = 300,
  }) : super(key: key);

  @override
  GenericDropdownState<T> createState() => GenericDropdownState<T>();
}

class GenericDropdownState<T> extends State<GenericDropdown<T>>
    with WidgetsBindingObserver {
  T? selectedValue;
  bool isDropdownOpen = false;
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  bool isFocused = false;

  late double screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    WidgetsBinding.instance.addObserver(this); // Add observer for lifecycle
  }

  @override
  void didUpdateWidget(covariant GenericDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If initialValue changes after async load, update selectedValue
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        selectedValue = widget.initialValue;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      closeDropdown(); // Close dropdown when app is inactive or paused
    }
  }

  void toggleDropdown() {
    if (isDropdownOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  void openDropdown() {
    if (_dropdownKey.currentContext == null) return;

    final renderBox = _dropdownKey.currentContext!.findRenderObject();
    if (renderBox == null || renderBox is! RenderBox) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _focusNode.requestFocus(); // Request focus when opening dropdown
    setState(() {
      isDropdownOpen = true;
      isFocused = true;
    });
  }

  void closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _focusNode.unfocus();

    // ✅ Fix: Don't call setState if widget is already disposed
    if (mounted) {
      setState(() {
        isDropdownOpen = false;
        isFocused = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) throw Exception("RenderObject not initialized");

    final offset = renderBox.localToGlobal(Offset.zero);

    final availableSpaceBelow =
        screenHeight - offset.dy - renderBox.size.height;
    final availableSpaceAbove = offset.dy;

    final bool showAbove =
        availableSpaceBelow < widget.maxHeight &&
        availableSpaceAbove > availableSpaceBelow;

    final dropdownHeight = widget.items.length * 56.0;
    final dropdownMaxHeight = (dropdownHeight < widget.maxHeight
        ? dropdownHeight
        : widget.maxHeight);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent background to detect taps outside dropdown
          GestureDetector(
            onTap: closeDropdown,
            child: Container(
              color: Colors.transparent, // Makes the overlay dismissible
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Positioned(
            top: showAbove
                ? offset.dy - dropdownMaxHeight - 10
                : offset.dy + renderBox.size.height + 10,
            left: offset.dx,
            width: renderBox.size.width,
            child: Container(
              decoration: BoxDecoration(
                color: ColorMappingImpl().white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColorMappingImpl().borderDefault,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorMappingImpl().borderDefault.withAlpha(128),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(maxHeight: dropdownMaxHeight),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final T item = widget.items[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    title: widget.displayItemBuilder(item),
                    trailing: selectedValue == item
                        ? Icon(
                            Icons.check,
                            color: ColorMappingImpl().textLabel,
                            size: 22,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        selectedValue = item;
                        closeDropdown();
                      });
                      widget.onChanged(item);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleDropdown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.show_title != null
              ? const SizedBox()
              : Text(
                  widget.title,
                  style: context.typography.smRegular.copyWith(
                    color: ColorMappingImpl().textLabel,
                  ),
                ),
          const SizedBox(height: 8),
          GestureDetector(
            key: _dropdownKey,
            onTap: toggleDropdown,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: ColorMappingImpl().white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isFocused
                      ? ColorMappingImpl().textLabel
                      : ColorMappingImpl().borderDefault,
                  width: isFocused ? 1.5 : 1,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: ColorMappingImpl().textLabel,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      selectedValue != null
                          ? (selectedValue as GenericListModel).name ??
                                "" // Display only the name
                          : widget.hint_text,
                      style: context.typography.mdRegular.copyWith(
                        color: selectedValue != null
                            ? ColorMappingImpl().textLabel
                            : ColorMappingImpl().background_black_default,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.expand_more, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ✅ فقط احذف الـ Overlay بشكل مباشر بدون أي setState أو logic آخر
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    _searchController.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);

    // ❌ لا تستدعي closeDropdown() هنا
    super.dispose();
  }
}
