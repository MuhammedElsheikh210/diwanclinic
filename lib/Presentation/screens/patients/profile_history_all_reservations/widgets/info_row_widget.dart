import '../../../../../index/index_main.dart';

class InfoRowWidget extends StatelessWidget {
  const InfoRowWidget({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Get.context!.typography.mdRegular),
          Text(value, style: Get.context!.typography.mdBold),
        ],
      ),
    );
  }
}


class InfoColumnWidget extends StatelessWidget {
  const InfoColumnWidget({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Get.context!.typography.mdRegular),
          Text(value, style: Get.context!.typography.mdBold),
        ],
      ),
    );
  }
}
