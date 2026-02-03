import '../../../../../../index/index_main.dart';

class ListViewExpenseHeader extends StatelessWidget {
  final ExpenseViewModel controller;
  final bool? show_appbar;

  const ListViewExpenseHeader({super.key, required this.controller,required this.show_appbar});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorMappingImpl().white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Divider(color: AppColors.grayLight, thickness: 0.4),
          HeaderWithFiler(
            title: "سجل المصروفات",
            subtitle: "جميع المصروفات الخاصة بالشركة",
            onFilterTap: () {
              controller.showFilterBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }
}
