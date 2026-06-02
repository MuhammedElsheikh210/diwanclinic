import 'package:diwanclinic/index/index_main.dart';
import 'package:diwanclinic/Presentation/parentControllers/order_Service/pharmacy_picker_service.dart';

class OrderConfirmationSheet extends StatefulWidget {
  final ReservationModel reservation;
  final LocalUser? user;
  final Function(ReservationModel) onConfirmed;

  const OrderConfirmationSheet({
    super.key,
    required this.reservation,
    required this.user,
    required this.onConfirmed,
  });

  @override
  State<OrderConfirmationSheet> createState() => _OrderConfirmationSheetState();
}

class _OrderConfirmationSheetState extends State<OrderConfirmationSheet> {
  late TextEditingController doseController;
  late TextEditingController notesController;

  bool _saveForNext = false;
  static const _kOrderPrefsKey = 'order_prefs_next';

  @override
  void initState() {
    super.initState();
    doseController = TextEditingController();
    notesController = TextEditingController();
    _loadSavedPrefs();
  }

  void _loadSavedPrefs() {
    final saved = StorageService().getData(_kOrderPrefsKey);
    if (saved != null) {
      _saveForNext = true;
      doseController.text = saved['doseDays'] ?? '';
      notesController.text = saved['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    doseController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────── Handle ──────
              Center(
                child: Container(
                  height: 5,
                  width: 45,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Center(
                child: AppText(
                  text: "تأكيد الطلب",
                  textStyle: context.typography.lgBold.copyWith(
                    color: ColorMappingImpl().textDisplay,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ────── Customer info card ──────
              _CustomerInfoCard(
                name: widget.reservation.patientName ?? widget.user?.name ?? "العميل",
                phone: widget.user?.phone ?? widget.reservation.patientPhone ?? "",
              ),
              const Divider(height: 30),

              // ────── Dose Days ──────
              AppText(
                text: "عدد أيام الجرعة (الإعادة بعد كام يوم !)",
                textStyle: context.typography.mdMedium.copyWith(
                  color: ColorMappingImpl().textSecondaryParagraph,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: doseController,
                hintText: "أدخل عدد الأيام",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // ────── Notes ──────
              AppText(
                text: "ملاحظات إضافية",
                textStyle: context.typography.mdMedium.copyWith(
                  color: ColorMappingImpl().textSecondaryParagraph,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: notesController,
                hintText: "أدخل أي ملاحظات للطبيب أو الصيدلية",
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // ────── Save for next order ──────
              GestureDetector(
                onTap: () => setState(() => _saveForNext = !_saveForNext),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: _saveForNext
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _saveForNext
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _saveForNext
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: _saveForNext
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppText(
                          text: "حفظ بياناتي للطلب القادم",
                          textStyle: context.typography.smMedium.copyWith(
                            color: _saveForNext
                                ? AppColors.primary
                                : AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _saveForNext,
                          onChanged: (v) => setState(() => _saveForNext = v),
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ────── Confirm Button ──────
              SizedBox(
                width: ScreenUtil().screenWidth,
                height: 55.h,
                child: PrimaryTextButton(
                  label: AppText(
                    text: "تأكيد الطلب",
                    textStyle: context.typography.mdBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  appButtonSize: AppButtonSize.large,
                  onTap: () async {
                    if (_saveForNext) {
                      await StorageService().setData(_kOrderPrefsKey, {
                        'doseDays': doseController.text.trim(),
                        'notes': notesController.text.trim(),
                      });
                    } else {
                      await StorageService().remove(_kOrderPrefsKey);
                    }

                    Loader.show();
                    final pharmacy = await PharmacyPickerService.pick();
                    final user = Get.find<UserSession>().user;

                    final order = OrderModel(
                      key: const Uuid().v4(),
                      reservationKey: widget.reservation.key,
                      patientuid: widget.reservation.patientUid,
                      pharmacyKey: pharmacy?.pharmacyId ?? pharmacy?.uid,
                      pharmacyPhone: pharmacy?.phone,
                      pharmacyFcmToken: pharmacy?.fcmToken,
                      patientKey: widget.reservation.patientUid,
                      doctorKey: widget.reservation.doctorUid,
                      fcmToken: widget.reservation.patientFcm,
                      doctorName: widget.reservation.doctorName,
                      patientName: widget.reservation.patientName,
                      clinicKey: widget.reservation.clinicKey,
                      createdBy: user?.uid,
                      phone: widget.user?.phone ?? "",
                      whatsApp: widget.user?.phone ?? "",
                      address: widget.user?.address ?? "",
                      doseDays: int.tryParse(doseController.text.trim()),
                      notes: notesController.text.trim(),
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      status: "approved",
                      prescriptionUrl1: widget.reservation.prescriptionUrl1,
                      prescriptionUrl2: widget.reservation.prescriptionUrl2,
                      prescriptionUrl3: widget.reservation.prescriptionUrl3,
                      prescriptionUrl4: widget.reservation.prescriptionUrl4,
                      prescriptionUrl5: widget.reservation.prescriptionUrl5,
                    );

                    OrderService().addOrderData(
                      order: order,
                      voidCallBack: (data) async {
                        if (data != ResponseStatus.success) {
                          Loader.showError("حدث خطأ أثناء إرسال الطلب");
                          return;
                        }

                        Get.find<HomePatientController>().upsertOrder(order);
                        if (Get.isRegistered<OrdersListViewModel>()) {
                          Get.find<OrdersListViewModel>().upsertOrder(order);
                        }

                        Get.back();
                        widget.reservation.isOrdered = true;
                        widget.onConfirmed(widget.reservation);

                        await WhatsAppManager.sendMessage(
                          to: widget.reservation.patientPhone ?? "",
                          body:
                              "📥 تم استلام الروشتة 👌\n\n⏳ جاري التسعير خلال 5 دقائق 💙",
                        );

                        Loader.showSuccess("تم إرسال طلب الروشتة بنجاح");
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Customer info display card (read-only)
// ──────────────────────────────────────────────────────────────

class _CustomerInfoCard extends StatelessWidget {
  final String name;
  final String phone;

  const _CustomerInfoCard({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: name,
                  textStyle: context.typography.mdBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: AppColors.textSecondaryParagraph,
                      ),
                      const SizedBox(width: 5),
                      AppText(
                        text: phone,
                        textStyle: context.typography.smRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
