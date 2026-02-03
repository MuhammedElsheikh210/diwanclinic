

import '../../index/index_main.dart';

class BottomNavigationView extends StatelessWidget {
  final Widget rightwidget;
  final Widget leftwidget;

  const BottomNavigationView(
      {Key? key, required this.leftwidget, required this.rightwidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorResources.COLOR_white,
      padding:
          const EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          rightwidget,
          leftwidget,
        ],
      ),
    );
  }
}
