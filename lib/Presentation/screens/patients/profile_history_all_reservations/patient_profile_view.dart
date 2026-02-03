import '../../../../index/index_main.dart';

class PatientAllHistoryView extends StatefulWidget {
  final String patient_key;

  const PatientAllHistoryView({super.key, required this.patient_key});

  @override
  State<PatientAllHistoryView> createState() => _PatientAllHistoryViewState();
}

class _PatientAllHistoryViewState extends State<PatientAllHistoryView> {
  late final PatientProfileAllHistoryViewModel controller;
  final HandleKeyboardService keyboardService = HandleKeyboardService();

  @override
  void initState() {
    controller = initController(() => PatientProfileAllHistoryViewModel());
    controller.getData(widget.patient_key);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('PatientAllHistoryView', 10);

    return GetBuilder<PatientProfileAllHistoryViewModel>(
      init: controller,
      builder: (vm) {
        final patient = vm.patientModel;

        return Scaffold(
          backgroundColor: AppColors.background_neutral_100,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.white,
            title: Text("الملف الشخصي", style: context.typography.lgBold),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColors.grayLight,
              ),
            ),
          ),

          body: KeyboardActions(
            config: keyboardService.buildConfig(context, keys),
            child: vm.reservations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPatientInfoCard(context, patient),
                const SizedBox(height: 25),

                /// Title Row
                Row(
                  children: [
                    const Icon(Icons.receipt_long,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      "سجل الكشوفات",
                      style: context.typography.lgBold.copyWith(
                        color: AppColors.text_primary_paragraph,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// History List
                ...vm.reservations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final r = entry.value;
                  return _buildReservationCard(
                    context,
                    r,
                    isFirst: index == 0,
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // 🟢 Patient Info Card — Clean Professional Style
  // ─────────────────────────────────────────────
  Widget _buildPatientInfoCard(BuildContext context, LocalUser? patient) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context,
            icon: Icons.person_outline,
            title: "بيانات العميل",
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            context,
            icon: Icons.badge_outlined,
            label: "الاسم",
            value: patient?.name ?? "-",
          ),
          _buildInfoRow(
            context,
            icon: Icons.phone,
            label: "الهاتف",
            value: patient?.phone ?? "-",
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context,
      {required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
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

  // ─────────────────────────────────────────────
  // 🟢 Reservation Card — New Clean Style (No Shadow)
  // ─────────────────────────────────────────────
  Widget _buildReservationCard(
      BuildContext context,
      ReservationModel res, {
        bool isFirst = false,
      }) {
    final prescriptions = <String>[
      if (res.prescriptionUrl1?.isNotEmpty == true) res.prescriptionUrl1!,
      if (res.prescriptionUrl2?.isNotEmpty == true) res.prescriptionUrl2!,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
      ),
      child: ExpansionTile(
        initiallyExpanded: isFirst,
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondaryParagraph,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        childrenPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Icon(Icons.calendar_month,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${res.appointmentDateTime ?? "-"} • ${res.reservationType ?? ""}",
                style: context.typography.mdBold.copyWith(
                  color: AppColors.text_primary_paragraph,
                ),
              ),
            ),
          ],
        ),
        children: [
          Text(
            "الروشتة",
            style: context.typography.lgBold.copyWith(
              color: AppColors.text_primary_paragraph,
            ),
          ),
          const SizedBox(height: 10),

          if (prescriptions.isEmpty)
            _buildEmptyPrescription(context)
          else
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: prescriptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _buildPrescriptionImage(
                  url: prescriptions[i],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPrescription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_information_outlined,
              color: AppColors.textSecondaryParagraph),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "لا توجد روشتة مرفقة لهذا الكشف",
              style: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionImage({required String url}) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => FullScreenImageView(imageUrl: url)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: 110,
          height: 90,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 🟢 Info Row
  // ─────────────────────────────────────────────
  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
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
