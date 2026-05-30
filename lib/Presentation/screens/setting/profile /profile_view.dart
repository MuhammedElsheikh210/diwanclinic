import 'package:diwanclinic/index/index_main.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileViewModel>(
      init: ProfileViewModel(),

      builder: (controller) {
        final userType = Get.find<UserSession>().user?.user.userType;

        final isPatient = userType == UserType.patient;
        final isAssistant = userType == UserType.assistant;
        final isDoctor = userType == UserType.doctor;
        final isPharmacy = userType == UserType.pharmacy;

        final currentUser = Get.find<UserSession>().user;
        final profileImage = currentUser?.user.profileImage;

        return Scaffold(
          backgroundColor: AppColors.white,

          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.white,
            centerTitle: true,

            title: Text(
              "تحديث الحساب",
              style: context.typography.lgBold.copyWith(
                color: AppColors.text_primary_paragraph,
              ),
            ),

            iconTheme: const IconThemeData(color: AppColors.primary),
          ),

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),

              child: ElevatedButton(
                onPressed:
                    controller.isLoading
                        ? null
                        : () => controller.updateProfile(),

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),

                child:
                    controller.isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          "حفظ التغييرات",
                          style: context.typography.mdBold.copyWith(
                            color: AppColors.white,
                          ),
                        ),
              ),
            ),
          ),

          body: Form(
            key: controller.formKey,

            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  // ── PROFILE IMAGE (non-patient) ──
                  if (!isPatient) ...[
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: AppColors.primary_light,
                          backgroundImage:
                              controller.pickedImage != null
                                  ? FileImage(controller.pickedImage!)
                                  : (profileImage != null &&
                                          profileImage.isNotEmpty
                                      ? NetworkImage(profileImage)
                                      : null),
                          child:
                              controller.pickedImage == null &&
                                      (profileImage == null ||
                                          profileImage.isEmpty)
                                  ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 6,
                          child: InkWell(
                            onTap: controller.pickImage,
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.edit,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ── NAME ──
                  _buildEditableInput(
                    context,
                    controller: controller.nameController,
                    label: "الإسم",
                    hint: "أدخل الإسم",
                    icon: Icons.person,
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? "أدخل الإسم" : null,
                  ),
                  const SizedBox(height: 20),

                  // ── PHONE ──
                  _buildEditableInput(
                    context,
                    controller: controller.phoneController,
                    label: "رقم الهاتف",
                    hint: "أدخل رقم الهاتف",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? "أدخل رقم الهاتف"
                                : null,
                  ),
                  const SizedBox(height: 20),

                  // ── ADDRESS (patient only) ──
                  if (isPatient) ...[
                    _buildEditableInput(
                      context,
                      controller: controller.addressController,
                      label: "العنوان",
                      hint: "أدخل العنوان",
                      icon: Icons.location_on,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "العنوان مطلوب"
                                  : null,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── ASSISTANT: transfer number + wallet type ──
                  if (isAssistant) ...[
                    _buildEditableInput(
                      context,
                      controller: controller.transferNumberController,
                      label: "رقم التحويل",
                      hint: "أدخل رقم التحويل الذي سيتم تحويل الأرباح عليه",
                      icon: Icons.account_balance_wallet_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "نوع المحفظة",
                        style: context.typography.mdBold.copyWith(
                          color: AppColors.text_primary_paragraph,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            value: controller.isInstaPay == 1,
                            onChanged: (v) => controller.setWalletType(
                              isInstaPay: v == true ? 1 : 0,
                            ),
                            title: const Text("إنستا باي"),
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            value: controller.isElectronicWallet == 1,
                            onChanged: (v) => controller.setWalletType(
                              isElectronicWallet: v == true ? 1 : 0,
                            ),
                            title: const Text("محفظة إلكترونية"),
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── DOCTOR-SPECIFIC FIELDS ──
                  if (isDoctor) ...[
                    _buildEditableInput(
                      context,
                      controller: controller.qualificationsController,
                      label: "المؤهلات",
                      hint: "أدخل مؤهلاتك العلمية",
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader(context, "روابط التواصل الاجتماعي"),
                    const SizedBox(height: 12),

                    _buildEditableInput(
                      context,
                      controller: controller.instagramController,
                      label: "رابط إنستجرام",
                      hint: "https://instagram.com/...",
                      icon: Icons.camera_alt_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),

                    _buildEditableInput(
                      context,
                      controller: controller.facebookController,
                      label: "رابط فيسبوك",
                      hint: "https://facebook.com/...",
                      icon: Icons.facebook_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),

                    _buildEditableInput(
                      context,
                      controller: controller.tiktokController,
                      label: "رابط تيك توك",
                      hint: "https://tiktok.com/@...",
                      icon: Icons.music_note_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 20),

                    _buildLocationPicker(context, controller),
                    const SizedBox(height: 20),

                    _buildSectionHeader(context, "الدفع الإلكتروني"),
                    const SizedBox(height: 12),

                    _buildToggleRow(
                      context,
                      label: "يدعم الدفع الإلكتروني",
                      value: controller.supportsOnlinePay,
                      onChanged: controller.setSupportsOnlinePay,
                    ),

                    if (controller.supportsOnlinePay) ...[
                      const SizedBox(height: 12),
                      _buildEditableInput(
                        context,
                        controller: controller.walletNumberController,
                        label: "رقم المحفظة",
                        hint: "رقم محفظة فودافون كاش / اتصالات",
                        icon: Icons.account_balance_wallet_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableInput(
                        context,
                        controller: controller.instapayNumberController,
                        label: "رقم InstaPay",
                        hint: "رقم حساب InstaPay",
                        icon: Icons.payment_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableInput(
                        context,
                        controller: controller.instapayLinkController,
                        label: "رابط InstaPay",
                        hint: "رابط الدفع عبر InstaPay",
                        icon: Icons.link_outlined,
                        keyboardType: TextInputType.url,
                      ),
                    ],

                    const SizedBox(height: 12),

                    _buildToggleRow(
                      context,
                      label: "يتطلب عربون عند الحجز",
                      value: controller.requiresDeposit,
                      onChanged: controller.setRequiresDeposit,
                    ),

                    const SizedBox(height: 20),
                  ],

                  // ── PHARMACY-SPECIFIC FIELDS ──
                  if (isPharmacy) ...[
                    _buildLocationPicker(context, controller),
                    const SizedBox(height: 20),

                    _buildSectionHeader(context, "الدفع الإلكتروني"),
                    const SizedBox(height: 12),

                    _buildEditableInput(
                      context,
                      controller: controller.walletNumberController,
                      label: "رقم المحفظة (اختياري)",
                      hint: "مثال: 01012345678",
                      icon: Icons.account_balance_wallet_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    _buildEditableInput(
                      context,
                      controller: controller.instapayNumberController,
                      label: "رقم InstaPay (اختياري)",
                      hint: "مثال: 01012345678",
                      icon: Icons.payment_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    _buildEditableInput(
                      context,
                      controller: controller.instapayLinkController,
                      label: "لينك InstaPay (اختياري)",
                      hint: "مثال: https://ipn.eg/...",
                      icon: Icons.link_outlined,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Section header ──
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: context.typography.smSemiBold.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ── Location picker ──
  Widget _buildLocationPicker(
    BuildContext context,
    ProfileViewModel controller,
  ) {
    final hasLocation =
        controller.selectedLatitude != null &&
        controller.selectedLongitude != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              hasLocation
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.borderNeutralPrimary,
        ),
        borderRadius: BorderRadius.circular(14),
        color: AppColors.primary_light.withOpacity(0.15),
      ),
      child: Row(
        children: [
          Icon(
            hasLocation ? Icons.location_on : Icons.location_off,
            color:
                hasLocation
                    ? AppColors.primary
                    : AppColors.textSecondaryParagraph,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasLocation
                  ? "الموقع: ${controller.selectedLatitude!.toStringAsFixed(5)}, ${controller.selectedLongitude!.toStringAsFixed(5)}"
                  : "لم يتم تحديد الموقع بعد",
              style: context.typography.smRegular.copyWith(
                color:
                    hasLocation
                        ? AppColors.textDefault
                        : AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          const SizedBox(width: 8),
          controller.isLoadingLocation
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : TextButton.icon(
                onPressed: controller.fetchCurrentLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: Text(hasLocation ? "تحديث" : "تحديد موقعي"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ── Toggle row ──
  Widget _buildToggleRow(
    BuildContext context, {
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary_light.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.typography.mdMedium),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  // ── Text input ──
  Widget _buildEditableInput(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,

      style: context.typography.mdMedium.copyWith(
        color: AppColors.text_primary_paragraph,
      ),

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelText: label,
        hintText: hint,

        labelStyle: context.typography.smRegular.copyWith(
          color: AppColors.textSecondaryParagraph,
        ),

        filled: true,
        fillColor: AppColors.primary_light.withOpacity(0.15),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorForeground),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorForeground),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
