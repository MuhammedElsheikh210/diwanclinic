import 'package:share_plus/share_plus.dart';
import '../../../index/index_main.dart';

class WhatsAppGroupView extends StatelessWidget {
  const WhatsAppGroupView({super.key});

  Uri get _groupUri => Uri.parse(Strings.url_whatsapp_group);

  Future<void> _openGroup(BuildContext context) async {
    try {
      final ok = await canLaunchUrl(_groupUri);
      if (ok) {
        await launchUrl(_groupUri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: _groupUri.toString()));
        EasyLoading.showToast("تعذّر فتح واتساب. تم نسخ الرابط للحافظة ✅");
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: _groupUri.toString()));
      EasyLoading.showToast("حدث خطأ أثناء الفتح. تم نسخ الرابط ✅");
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _groupUri.toString()));
    EasyLoading.showToast("تم نسخ الرابط ✅");
  }

  Future<void> _shareLink() async {
    Share.share(
      "📢 انضم إلى جروب المساعدين على واتساب 👇\n${_groupUri.toString()}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<UserSession>().user;

    final isAssistant = user?.user.userType?.name == Strings.assistant;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          isAssistant ? "جروب المساعدين" : "مجموعة واتساب",
          style: context.typography.lgBold.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Images.logo_brown,
                height: 100.h,
                width: 200.w,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                isAssistant
                    ? "انضم إلى جروب المساعدين لتلقي التعليمات اليومية والتحديثات الهامة ✨"
                    : "انضم إلى مجموعتنا على واتساب للبقاء على تواصل وتلقي التحديثات.",
                textAlign: TextAlign.center,
                style: context.typography.mdMedium.copyWith(
                  color: AppColors.background_black,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grayLight.withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderNeutralPrimary.withOpacity(.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Strings.url_whatsapp_group,
                        style: context.typography.smRegular.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: ScreenUtil().screenWidth,
                height: 50.h,
                child: PrimaryTextButton(
                  onTap: () => _openGroup(context),
                  label: AppText(
                    text: "🚀 انضم الآن",
                    textStyle: context.typography.lgBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyLink,
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text("نسخ الرابط"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareLink,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text("مشاركة"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
