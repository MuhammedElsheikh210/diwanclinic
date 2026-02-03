import 'package:diwanclinic/Presentation/screens/Authentication/HeplCenter/HelpCenterViewModel.dart';
import '../../../../index/index_main.dart';

class HelpCenterView extends GetView<HelpCenterViewModel> {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text("خدمات الدعم".tr, style: context.typography.lgBold),
      ),
      body: SafeArea(
        child: GetBuilder<HelpCenterViewModel>(
          init: HelpCenterViewModel(),
          builder: (controller) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                // 🔹 Illustration At Top
                Center(
                  child: Image.asset(
                    Images.splash,
                    width: 220,
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Big Title
                Text(
                  "مركز المساعدة",
                  style: context.typography.xlBold.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                Text(
                  "نحن هنا لمساعدتك طوال الوقت، اختر وسيلة التواصل المفضلة لديك.",
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // 🔹 Section Label
                Text("طرق التواصل", style: context.typography.mdBold),

                const SizedBox(height: 16),

                // 🔹 Cards
                _buildContactCard(
                  context,
                  title: "اتصل بنا".tr,
                  subtitle: "تواصل معنا مباشرة عبر الهاتف",
                  onTap: () => controller.makeCall(),
                  icon: const Icon(Icons.phone),
                  textColor: AppColors.primary,
                ),

                _buildContactCard(
                  context,
                  title: "تواصل عبر واتساب".tr,
                  subtitle: "دعم فوري عبر الواتساب",
                  onTap: () => controller.openwhatsapp(),
                  icon: const Svgicon(
                    icon: IconsConstants.phone,
                    color: AppColors.background_black,
                    width: 26,
                    height: 26,
                  ),
                  textColor: AppColors.successForeground,
                ),

                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🔸 Better looking card
  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Widget icon,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      highlightColor: AppColors.primary.withValues(alpha: 0.06),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.background_black.withValues(alpha: 0.06),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),

            const SizedBox(width: 16),

            // Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typography.mdBold.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.borderNeutralPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
