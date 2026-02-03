// import '../../../../../index/index_main.dart';
//
// class TabsWidget extends StatefulWidget {
//   final MerchantViewModel controller;
//
//   const TabsWidget({
//     Key? key,
//     required this.controller,
//   }) : super(key: key);
//
//   @override
//   State<TabsWidget> createState() => _TabsWidgetState();
// }
//
// class _TabsWidgetState extends State<TabsWidget> {
//   late ScrollController _scrollController;
//
//   final List<Map<String, dynamic>> _tabs = [
//     {"text": "إتفاقيات المزارعين", "index": 0},
//     {"text": "ملخص اتفاقيات المزارعين", "index": 1},
//     {"text": "إتفاقيات المشترين", "index": 2},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTab());
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _scrollToCurrentTab();
//   }
//
//   void _scrollToCurrentTab() {
//     if (widget.controller.tab_index == 1) return; // No scrolling for index 1
//
//     double offset = widget.controller.tab_index * 50; // Adjust scroll offset based on tab width
//     _scrollController.animateTo(
//       offset,
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   void _handleTabTap(int index) {
//     widget.controller.tabsActions(index); // Always execute action
//     if (index != 1) _scrollToCurrentTab(); // Scroll only for index 0 & 2
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = ColorMappingImpl();
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: SizedBox(
//         height: 45, // Height for the horizontal list
//         child: ListView.builder(
//           controller: _scrollController, // Attach ScrollController
//           padding: EdgeInsets.zero,
//           scrollDirection: Axis.horizontal,
//           itemCount: _tabs.length,
//           itemBuilder: (context, index) {
//             final tab = _tabs[index];
//             final bool isSelected = widget.controller.tab_index == tab["index"];
//
//             return GestureDetector(
//               onTap: () => _handleTabTap(tab["index"]), // Handle tap logic
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? colors.background_black_default
//                       : colors.background_neutral_default,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: AppText(
//                     text: tab["text"],
//                     textStyle: context.typography.mdRegular.copyWith(
//                       color: isSelected ? colors.white : colors.textDefault,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
