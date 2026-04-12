import 'package:diwanclinic/index/index_main.dart';

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
  late TextEditingController phoneController;
  late TextEditingController whatsappController;
  late TextEditingController addressController;
  late TextEditingController doseController;
  late TextEditingController notesController;

  bool isWhatsAppSame = true; // ✅ default true

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.user?.phone ?? "");
    whatsappController = TextEditingController(text: widget.user?.phone ?? "");
    addressController = TextEditingController(text: widget.user?.address ?? "");
    doseController = TextEditingController();
    notesController = TextEditingController();

    // If no WhatsApp stored, default to same as phone
    if (whatsappController.text.isEmpty ||
        whatsappController.text == phoneController.text) {
      isWhatsAppSame = true;
      whatsappController.text = phoneController.text;
    } else {
      isWhatsAppSame = false;
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    whatsappController.dispose();
    addressController.dispose();
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
              // ────── Header ──────
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
                  text: "تأكيد بيانات العميل",
                  textStyle: context.typography.lgBold.copyWith(
                    color: ColorMappingImpl().textDisplay,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ────── Phone ──────
              AppText(
                text: "رقم الهاتف",
                textStyle: context.typography.mdMedium.copyWith(
                  color: ColorMappingImpl().textSecondaryParagraph,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: phoneController,
                hintText: "أدخل رقم الهاتف",
                keyboardType: TextInputType.phone,
                onChanged: (val) {
                  if (isWhatsAppSame) {
                    whatsappController.text = val;
                  }
                },
              ),
              const SizedBox(height: 12),

              // ────── WhatsApp Same Checkbox ──────
              Row(
                children: [
                  Checkbox(
                    value: isWhatsAppSame,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() {
                        isWhatsAppSame = v ?? true;
                        if (isWhatsAppSame) {
                          whatsappController.text = phoneController.text;
                        } else {
                          whatsappController.clear();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: AppText(
                      text: "هذا هو رقم الواتساب",
                      textStyle: context.typography.smMedium.copyWith(
                        color: ColorMappingImpl().textSecondaryParagraph,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ────── WhatsApp Field (only if unchecked) ──────
              if (!isWhatsAppSame) ...[
                AppText(
                  text: "رقم الواتساب",
                  textStyle: context.typography.mdMedium.copyWith(
                    color: ColorMappingImpl().textSecondaryParagraph,
                  ),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  controller: whatsappController,
                  hintText: "أدخل رقم الواتساب",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
              ],

              // ────── Address ──────
              AppText(
                text: "العنوان",
                textStyle: context.typography.mdMedium.copyWith(
                  color: ColorMappingImpl().textSecondaryParagraph,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: addressController,
                hintText: "أدخل عنوان المريض",
                maxLines: 2,
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
              const SizedBox(height: 30),

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
                    Loader.show();
                    final pharmacy = await getPharmacyData();
                    final user = Get.find<UserSession>().user;

                    final order = OrderModel(
                      key: const Uuid().v4(),
                      reservationKey: widget.reservation.key,
                      patientuid: widget.reservation.patientUid,
                      pharmacyPhone: pharmacy?.phone,
                      pharmacyFcmToken: pharmacy?.fcmToken,
                      patientKey: widget.reservation.patientKey,
                      doctorKey: widget.reservation.doctorKey,
                      fcmToken: widget.reservation.fcmToken_patient,
                      doctorName: widget.reservation.doctorName,
                      patientName: widget.reservation.patientName,
                      clinicKey: widget.reservation.clinicKey,
                      createdBy: user?.uid,
                      phone: phoneController.text.trim(),
                      whatsApp: whatsappController.text.trim(),
                      address: addressController.text.trim(),
                      doseDays: int.tryParse(doseController.text.trim()),
                      notes: notesController.text.trim(),
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      status: "pending",
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

                        Get.back();
                        widget.reservation.isOrdered = true;
                        widget.onConfirmed(widget.reservation);
                        // 🔔 Notification للصيدلية
                        await NotificationHandler().sendToClinicAssistants(
                          title: "💊 طلب روشتة جديد",
                          body: "طلب جديد من ${order.patientName}",
                          reservation: widget.reservation,
                          assistants: [pharmacy],
                          notificationType: "new_pharmacy_order",
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

  Future<LocalUser?> getPharmacyData() async {
    final completer = Completer<LocalUser?>();

    await AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "userType = ?",
        whereArgs: ["pharmacy"],
        limit: 1,
      ),
      voidCallBack: (List<LocalUser?> users) {
        Loader.dismiss();

        if (users.isNotEmpty && users.first != null) {
          completer.complete(users.first);
        } else {
          completer.complete(null); // ✅ بدل LocalUser()
        }
      },
    );

    return completer.future;
  }
}
