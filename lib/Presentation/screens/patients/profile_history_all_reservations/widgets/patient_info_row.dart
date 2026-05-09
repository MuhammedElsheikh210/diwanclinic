import '../../../../../index/index_main.dart';

class PatientInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PatientInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),

          const SizedBox(width: 8),

          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.typography.smRegular.copyWith(
                color:
                AppColors.textSecondaryParagraph,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.typography.mdBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
          ),
        ],
      ),
    );
  }
}