import '../../index/index_main.dart';

class NoDataWidget extends StatelessWidget {
  final String? image;
  final String? title;
  final Function()? reLoadData;

  const NoDataWidget({super.key, this.title, this.image, this.reLoadData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title ?? "لا يوجد بيانات", style: context.typography.mdBold),
          Visibility(
            visible: reLoadData != null,
            child: PrimaryTextButton(
              label: AppText(
                text: "إعادة تحميل البيانات",
                textStyle: context.typography.mdRegular,
              ),
              onTap: reLoadData,
            ),
          ),
        ],
      ),
    );
  }
}
