import '../../../../../index/index_main.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.typography.smSemiBold,
        ),
        Text(
          value,
          style: context.typography.smRegular,
        ),
      ],
    );
  }
}