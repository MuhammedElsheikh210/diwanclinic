import '../../../../../index/index_main.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 22,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: context.typography.lgBold.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}