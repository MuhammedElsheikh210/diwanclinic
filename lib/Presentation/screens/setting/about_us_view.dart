import 'package:diwanclinic/index/index_main.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text("من نحن", style: context.typography.lgBold),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          """
تطبيق  لينك هو منصة طبية متكاملة تساعد المرضى على الحجز السريع لدى الأطباء، متابعة الروشتة، طلب الأدوية، وإدارة جميع تفاصيل الزيارة بكل سهولة.

✨ أهدافنا:
- تسهيل الوصول للخدمات الطبية.
- تنظيم الحجز ومنع الزحام داخل العيادات.
- توفير التواصل السهل بين الطبيب والمريض.
- تقديم خدمات إضافية مثل توصيل الأدوية والعروض الخاصة.

🩺  لينك — صحتك أولويتنا.
          """,
          style: context.typography.mdMedium.copyWith(
            height: 1.7,
            color: AppColors.text_primary_paragraph,
          ),
        ),
      ),
    );
  }
}
