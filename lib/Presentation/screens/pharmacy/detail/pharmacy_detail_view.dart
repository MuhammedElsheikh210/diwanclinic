import '../../../../index/index_main.dart';

Future<void> _openSheet(BuildContext context, Widget child) {
  Get.delete<CreatePharmacyViewModel>();
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 15.w, right: 15.w, bottom: 30.h, top: 20.h,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: child,
      ),
    ),
  );
}

class PharmacyDetailView extends StatelessWidget {
  final String pharmacyId;
  final String? pharmacyName;

  const PharmacyDetailView({
    Key? key,
    required this.pharmacyId,
    this.pharmacyName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyDetailViewModel>(
      init: PharmacyDetailViewModel(pharmacyId: pharmacyId),
      builder: (controller) {
        final primary = controller.primary;
        final staff = controller.staffOnly;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: Text(
              primary?.name ?? pharmacyName ?? "الصيدلية",
              style: context.typography.lgBold,
            ),
            elevation: 1,
            backgroundColor: AppColors.white,
          ),
          floatingActionButton: InkWell(
            onTap: () async {
              await _openSheet(
                context,
                CreatePharmacyView(parentPharmacyId: pharmacyId),
              );
              await controller.loadStaff();
            },
            child: const Svgicon(icon: IconsConstants.fab_Button),
          ),
          body: controller.isLoading
              ? const ShimmerLoader()
              : ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  children: [
                    if (primary != null) ...[
                      _PharmacyInfoCard(pharmacy: primary, controller: controller),
                      SizedBox(height: 20.h),
                    ],
                    _StaffSection(staff: staff, controller: controller),
                  ],
                ),
        );
      },
    );
  }
}

// ── Pharmacy primary info card ─────────────────────────────────────────────

class _PharmacyInfoCard extends StatelessWidget {
  final LocalUser pharmacy;
  final PharmacyDetailViewModel controller;

  const _PharmacyInfoCard({required this.pharmacy, required this.controller});

  @override
  Widget build(BuildContext context) {
    final p = pharmacy.asPharmacy;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        border: Border.all(color: AppColors.borderNeutralPrimary),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_pharmacy, color: AppColors.primary, size: 22),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  pharmacy.name ?? "",
                  style: context.typography.lgBold,
                ),
              ),
              InkWell(
                onTap: () async {
                  await _openSheet(context, CreatePharmacyView(pharmacy: pharmacy));
                  await controller.loadStaff();
                },
                child: Svgicon(icon: IconsConstants.edit_btn, height: 28.h, width: 28.w),
              ),
              SizedBox(width: 6.w),
              InkWell(
                onTap: () => controller.deleteMember(pharmacy),
                child: Svgicon(icon: IconsConstants.delete_btn, height: 28.h, width: 28.w),
              ),
            ],
          ),

          if (pharmacy.phone != null) ...[
            SizedBox(height: 12.h),
            _InfoRow(icon: Icons.phone_outlined, label: pharmacy.phone!),
          ],

          if (pharmacy.latitude != null && pharmacy.longitude != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label:
                  "${pharmacy.latitude!.toStringAsFixed(5)}, ${pharmacy.longitude!.toStringAsFixed(5)}",
            ),
          ],

          if (p != null && (p.hasWallet || p.hasInstapay)) ...[
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.borderNeutralPrimary),
            SizedBox(height: 12.h),
            Row(
              children: [
                const Icon(Icons.payment_outlined, color: AppColors.primary, size: 16),
                SizedBox(width: 6.w),
                Text(
                  "بيانات الدفع",
                  style: context.typography.smSemiBold.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            if (p.hasWallet) ...[
              SizedBox(height: 6.h),
              _InfoRow(
                icon: Icons.account_balance_wallet_outlined,
                label: "محفظة: ${p.walletNumber}",
              ),
            ],
            if (p.instapayNumber != null && p.instapayNumber!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              _InfoRow(
                icon: Icons.credit_card_outlined,
                label: "InstaPay: ${p.instapayNumber}",
              ),
            ],
            if (p.instapayLink != null && p.instapayLink!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              _InfoRow(icon: Icons.link_outlined, label: p.instapayLink!),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryParagraph),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      ],
    );
  }
}

// ── Staff section ──────────────────────────────────────────────────────────

class _StaffSection extends StatelessWidget {
  final List<LocalUser> staff;
  final PharmacyDetailViewModel controller;

  const _StaffSection({required this.staff, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_outline, color: AppColors.primary, size: 20),
            SizedBox(width: 8.w),
            Text("الصيادلة الموظفون", style: context.typography.mdBold),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${staff.length}",
                style: context.typography.smMedium
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (staff.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                children: [
                  const Icon(Icons.person_add_outlined,
                      size: 40, color: AppColors.textSecondaryParagraph),
                  SizedBox(height: 8.h),
                  Text(
                    "لا يوجد موظفون بعد\nاضغط + لإضافة صيدلي",
                    textAlign: TextAlign.center,
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...staff.map(
            (member) => _StaffCard(member: member, controller: controller),
          ),
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  final LocalUser member;
  final PharmacyDetailViewModel controller;

  const _StaffCard({required this.member, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderNeutralPrimary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: const BoxDecoration(
              color: AppColors.borderNeutralPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline,
                size: 18, color: AppColors.textSecondaryParagraph),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name ?? "", style: context.typography.smMedium),
                if (member.phone != null)
                  Text(
                    member.phone!,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              await _openSheet(context, CreatePharmacyView(pharmacy: member));
              await controller.loadStaff();
            },
            child: Svgicon(icon: IconsConstants.edit_btn, height: 26.h, width: 26.w),
          ),
          SizedBox(width: 6.w),
          InkWell(
            onTap: () => controller.deleteMember(member),
            child: Svgicon(icon: IconsConstants.delete_btn, height: 26.h, width: 26.w),
          ),
        ],
      ),
    );
  }
}
