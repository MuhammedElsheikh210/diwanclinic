import '../../../../../index/index_main.dart';

class QtyBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QtyBtn(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background_neutral_25,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: context.typography.xlBold),
      ),
    );
  }
}
