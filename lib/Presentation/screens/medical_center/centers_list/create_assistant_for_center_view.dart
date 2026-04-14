import '../../../../../index/index_main.dart';

class CreateAssistantViewForCenter extends StatelessWidget {
  final String medicalCenterKey;

  const CreateAssistantViewForCenter({
    super.key,
    required this.medicalCenterKey,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateAssistantViewModel>(
      init: CreateAssistantViewModel(medicalCenterKey: medicalCenterKey),
      builder: (_) {
        return const CreateAssistantView(doctor_uid: '',);
      },
    );
  }
}
