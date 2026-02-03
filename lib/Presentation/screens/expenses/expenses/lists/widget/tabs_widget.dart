import '../../../../../../index/index_main.dart';

class TabsWidget extends StatefulWidget {
  final ExpenseViewModel controller;

  const TabsWidget({Key? key, required this.controller}) : super(key: key);

  @override
  State<TabsWidget> createState() => _RefundTabsWidgetState();
}

class _RefundTabsWidgetState extends State<TabsWidget> {
  late ScrollController _scrollController;

  final List<Map<String, dynamic>> _tabs = [
    {"text": "المصروفات القادمة", "index": 0},
    {"text": "المصروفات المنتهية", "index": 1},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTab());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollToCurrentTab();
  }

  void _scrollToCurrentTab() {
    if (widget.controller.tab_index == 1) return; // Do NOT scroll for index 1

    double offset =
        widget.controller.tab_index *
        60; // Adjust scroll offset based on tab width
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleTabTap(int index) {
    widget.controller.tabsActions(index); // Always execute action
    if (index != 1) _scrollToCurrentTab(); // Only scroll if index is 0 or 2
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorMappingImpl();

    return Container(
      color: AppColors.white,
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      height: 45.h, // Height for the horizontal list
      child: ListView.builder(
        controller: _scrollController,
        // Attach the ScrollController
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final bool isSelected = widget.controller.tab_index == tab["index"];

          return GestureDetector(
            onTap: () => _handleTabTap(tab["index"]), // Handle tap logic
            child: AnimatedContainer(
              width: MediaQuery.of(context).size.width / 2 - 10.w,
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? colors.background_black_default
                        : colors.background_neutral_default,
                borderRadius:
                    index == 0
                        ? const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        )
                        : index == 1
                        ? const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        )
                        : BorderRadius.circular(0),
              ),
              child: Center(
                child: AppText(
                  text: tab["text"],
                  textStyle: context.typography.mdRegular.copyWith(
                    color: isSelected ? colors.white : colors.textDefault,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
