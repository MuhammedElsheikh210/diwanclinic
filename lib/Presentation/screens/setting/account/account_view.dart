import 'dart:io';

import 'package:share_plus/share_plus.dart';
import '../../../../index/index_main.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountViewModel>(
      init: AccountViewModel(),
      builder: (controller) {
        final userType = LocalUser().getUserData().userType?.name;

        return Scaffold(
          backgroundColor: AppColors.background_neutral_100,
          appBar: AppBar(
            title: Text("الإعدادات", style: context.typography.lgBold),
            backgroundColor: AppColors.white,
            elevation: 1,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Profile Header
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    await Get.to(() => const ProfileView(), binding: Binding());
                    controller.loadUserData();
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Hero(
                          tag: "profile_photo",
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            backgroundImage: controller.doctorImage != null
                                ? NetworkImage(controller.doctorImage!)
                                : null,
                            child: controller.doctorImage == null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: Image.asset(Images.splash),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.doctorName ?? "الاسم",
                                style: context.typography.lgBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.doctorPhone ?? "",
                                style: context.typography.smRegular.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit, color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Divider(
                    color: AppColors.borderNeutralPrimary.withOpacity(0.2),
                    thickness: 1,
                  ),
                ),

                // 🔹 Settings Section
                if (userType == "doctor") ...[
                  _sectionTitle(context, "الإعدادات"),
                  _modernMenuCard(context, [
                    // _menuItem(
                    //   context,
                    //   icon: Icons.local_hospital_outlined,
                    //   label: "ارشيف المرضي",
                    //   onTap: () => Get.to(() => const ArchivePatientView()),
                    // ),
                    _menuItem(
                      context,
                      icon: Icons.local_hospital_outlined,
                      label: "العيادات",
                      onTap: () => Get.toNamed(clinicView),
                    ),
                    _menuItem(
                      context,
                      icon: Icons.group_outlined,
                      label: "المساعدين",
                      onTap: () => Get.toNamed(assistantView),
                    ),

                    _menuItemWithStatus(
                      context,
                      icon: Icons.event_busy_outlined,
                      label: "إدارة أيام العمل",
                      isEnabled: true, // 👈 هنا الحالة (On / Off)
                      onTap: () => Get.toNamed(openclosereservationView),
                    ),
                  ]),
                ],

                const SizedBox(height: 12),

                // 🔹 Info Section
                _sectionTitle(context, "معلومات"),
                _modernMenuCard(context, [
                  _menuItem(
                    context,
                    icon: Icons.support_agent_outlined,
                    label: "الدعم الفني",
                    onTap: () => Get.toNamed(helpCenterView),
                  ),
                ]),

                if (userType == "assistant") ...[
                  const SizedBox(height: 12),
                  _modernMenuCard(context, [
                    _menuItem(
                      context,
                      icon: Icons.support_agent_outlined,
                      label: "مجموعة الواتس اب",
                      onTap: () => Get.toNamed(whatsAppGroupView),
                    ),
                  ]),

                  _menuItemWithStatus(
                    context,
                    icon: Icons.event_busy_outlined,
                    label: "إدارة أيام العمل",
                    isEnabled: true, // 👈 هنا الحالة (On / Off)
                    onTap: () => Get.toNamed(openclosereservationView),
                  ),

                  _menuItemWithStatus(
                    context,
                    icon: Icons.description_outlined,
                    label: "الكشوفات الورقية",
                    isEnabled: true, // 👈 On / Off الكشوفات الورقية
                    onTap: () => Get.toNamed(legacyQueueView),
                  ),
                ],

                const SizedBox(height: 12),

                _sectionTitle(context, "عام"),

                _modernMenuCard(context, [
                  // Notifications only for doctor/assistant
                  if (userType != "patient")
                    _menuItem(
                      context,
                      icon: Icons.notifications,
                      label: "الإشعارات",
                      onTap: () => Get.toNamed(notificationsView),
                    ),

                  if (userType != "patient") const SizedBox(height: 20),

                  // Change password (same for all)
                  _menuItem(
                    context,
                    icon: Icons.lock_outline,
                    label: "تغيير كلمة المرور",
                    onTap: () => _showChangePasswordSheet(context, controller),
                  ),
                  const SizedBox(height: 20),
                ]),

                const SizedBox(height: 20),

                // ⭐⭐⭐ Patient-only features ⭐⭐⭐
                _sectionTitle(context, "عن التطبيق"),

                _modernMenuCard(context, [
                  _menuItem(
                    context,
                    icon: Icons.info_outline,
                    label: "من نحن",
                    onTap: () => Get.to(() => const AboutUsView()),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.star_rate_outlined,
                    label: "قيم التطبيق",
                    onTap: openStorePage,
                  ),
                  _menuItem(
                    context,
                    icon: Icons.share_outlined,
                    label: "مشاركة التطبيق",
                    onTap: _shareApp,
                  ),
                ]),

                // Logout always shown
                _menuItem(
                  context,
                  icon: Icons.logout_rounded,
                  color: AppColors.errorForeground,
                  label: "تسجيل الخروج",
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItemWithStatus(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final Color statusColor = isEnabled
        ? Colors.green
        : AppColors.errorForeground;

    final String statusText = isEnabled ? "مفعل" : "غير مفعل";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.typography.mdMedium.copyWith(
                  color: AppColors.text_primary_paragraph,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: context.typography.xsMedium.copyWith(color: statusColor),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondaryParagraph,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openStorePage() async {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.elsheikh.marketingwhats";

    const String appStoreLink =
        "https://apps.apple.com/us/app/diwan-%D8%AF%D9%8A%D9%88%D8%A7%D9%86%D9%83/id6630387762";

    final Uri androidUri = Uri.parse(playStoreLink);
    final Uri iosUri = Uri.parse(appStoreLink);

    try {
      if (Platform.isIOS) {
        if (!await launchUrl(iosUri, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $iosUri';
        }
      } else {
        if (!await launchUrl(
          androidUri,
          mode: LaunchMode.externalApplication,
        )) {
          throw 'Could not launch $androidUri';
        }
      }
    } catch (e) {
      debugPrint("Store launch error: $e");
      Loader.showError("تعذر فتح صفحة التقييم");
    }
  }

  void _shareApp() {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.elsheikh.marketingwhats";

    const String appStoreLink =
        "https://apps.apple.com/us/app/diwan-%D8%AF%D9%8A%D9%88%D8%A7%D9%86%D9%83/id6630387762";

    final String link = Platform.isIOS ? appStoreLink : playStoreLink;

    Share.share(
      "جرّب تطبيق لينك كلينك الآن لحجز الكشوفات والمتابعة الطبية بسهولة!\n\n$link",
      subject: "تطبيق لينك",
    );
  }

  // ───────────────────────────────
  // 🔒 Bottom Sheet for Change Password
  // ───────────────────────────────
  void _showChangePasswordSheet(
    BuildContext context,
    AccountViewModel controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "تغيير كلمة المرور",
                        style: context.typography.lgBold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    _passwordField(
                      context,
                      controller: controller.oldPasswordController,
                      label: "كلمة المرور الحالية",
                      icon: Icons.lock_clock_outlined,
                    ),
                    const SizedBox(height: 20),

                    _passwordField(
                      context,
                      controller: controller.newPasswordController,
                      label: "كلمة المرور الجديدة",
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 20),

                    _passwordField(
                      context,
                      controller: controller.confirmPasswordController,
                      label: "تأكيد كلمة المرور الجديدة",
                      icon: Icons.lock_reset_outlined,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: PrimaryTextButton(
                        appButtonSize: AppButtonSize.xxLarge,
                        label: AppText(
                          text: "تحديث",
                          textStyle: context.typography.mdMedium,
                        ),
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          Get.back();
                          await controller.changePassword();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _passwordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ───────────────────────────────
  // 🔻 Logout
  // ───────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const LogoutDialog());
  }

  // ───────────────────────────────
  // 🧱 Reusable Widgets
  // ───────────────────────────────
  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        title,
        style: context.typography.mdBold.copyWith(
          color: AppColors.textSecondaryParagraph,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _modernMenuCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                color: AppColors.borderNeutralPrimary.withOpacity(0.2),
              ),
          ],
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color ?? AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.typography.mdMedium.copyWith(
                  color: color ?? AppColors.text_primary_paragraph,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondaryParagraph,
            ),
          ],
        ),
      ),
    );
  }
}
