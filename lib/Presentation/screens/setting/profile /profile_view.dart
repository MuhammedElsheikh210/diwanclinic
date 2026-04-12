import 'package:diwanclinic/index/index_main.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileViewModel>(
      init: ProfileViewModel(),
      builder: (controller) {
        final isPatient =
            Get.find<UserSession>().user?.user.userType == UserType.patient;

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
                  // -----------------------------------------------------------
                  // 🔹 PROFILE IMAGE → HIDDEN FOR PATIENT
                  // -----------------------------------------------------------
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

                  // -----------------------------------------------------------
                  // 🔹 NAME
                  // -----------------------------------------------------------
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

                  // -----------------------------------------------------------
                  // 🔹 PHONE
                  // -----------------------------------------------------------
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

                  // -----------------------------------------------------------
                  // 🔹 ADDRESS → ONLY FOR PATIENT
                  // -----------------------------------------------------------
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

                  // -----------------------------------------------------------
                  // 🔹 TRANSFER NUMBER → HIDE FOR PATIENT
                  // -----------------------------------------------------------
                  if (!isPatient) ...[
                    _buildEditableInput(
                      context,
                      controller: controller.transferNumberController,
                      label: "رقم التحويل",
                      hint: "أدخل رقم التحويل الذي سيتم تحويل الأرباح عليه",
                      icon: Icons.account_balance_wallet_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // -----------------------------------------------------------
                    // 🔹 WALLET TYPES → HIDE FOR PATIENT
                    // -----------------------------------------------------------
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
                            onChanged: (v) {
                              controller.setWalletType(
                                isInstaPay: v == true ? 1 : 0,
                              );
                            },
                            title: const Text("إنستا باي"),
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            value: controller.isElectronicWallet == 1,
                            onChanged: (v) {
                              controller.setWalletType(
                                isElectronicWallet: v == true ? 1 : 0,
                              );
                            },
                            title: const Text("محفظة إلكترونية"),
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🔹 Modern Editable Input Field
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
