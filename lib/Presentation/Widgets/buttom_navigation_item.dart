import '../../index/index_main.dart';

class BottomNavigationButton extends StatelessWidget {
  final String title;
  final Function? onpress;
  bool? isvalidate;

  BottomNavigationButton({
    Key? key,
    required this.title,
    this.isvalidate,
    required this.onpress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: CustomButtonWidget(
        width: MediaQuery.of(context).size.width,
        height: 50,
        borderradius: 25,
        backgroundcolor:
            isvalidate == true
                ? ColorResources.COLOR_Primary
                : ColorResources.COLOR_GREY90,
        onpress:
            onpress ??
            () {
              onpress!();
            },
        text: Text(
          title,
          style: context.typography.mdMedium.copyWith(
            color:
                isvalidate == true
                    ? AppColors.white
                    : AppColors.grayMedium,
          ),
        ),
      ),
    );
  }
}
