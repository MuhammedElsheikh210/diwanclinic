import 'package:diwanclinic/index/index_main.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "سياسة الخصوصية",
          style: context.typography.lgBold.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _sectionTitle(context, "مقدمة"),
              _sectionBody(
                context,
                "نحن في تطبيق Link نلتزم بحماية خصوصيتك وضمان أمان بياناتك الشخصية. توضح هذه السياسة كيفية جمع المعلومات واستخدامها وحمايتها.",
              ),

              SizedBox(height: 24.h),

              _sectionTitle(context, "المعلومات التي نقوم بجمعها"),
              _sectionBody(
                context,
                "قد نقوم بجمع المعلومات التالية:\n"
                    "• الاسم ورقم الهاتف.\n"
                    "• بيانات الحجوزات والطلبات.\n"
                    "• معلومات الجهاز لأغراض تحسين الأداء.\n"
                    "• رموز الإشعارات (FCM) لإرسال التنبيهات.",
              ),

              SizedBox(height: 24.h),

              _sectionTitle(context, "كيفية استخدام المعلومات"),
              _sectionBody(
                context,
                "نستخدم المعلومات من أجل:\n"
                    "• إدارة الحجوزات ومتابعتها.\n"
                    "• تنفيذ طلبات العلاج.\n"
                    "• إرسال الإشعارات المتعلقة بحالتك.\n"
                    "• تحسين تجربة المستخدم داخل التطبيق.",
              ),

              SizedBox(height: 24.h),

              _sectionTitle(context, "مشاركة المعلومات"),
              _sectionBody(
                context,
                "نحن لا نقوم ببيع أو تأجير بياناتك لأي طرف ثالث. قد يتم مشاركة البيانات فقط مع الجهات الطبية المعنية لإتمام الخدمة.",
              ),

              SizedBox(height: 24.h),

              _sectionTitle(context, "حماية البيانات"),
              _sectionBody(
                context,
                "نطبق إجراءات أمان تقنية وتنظيمية لحماية بياناتك من الوصول غير المصرح به أو التعديل أو الإفصاح.",
              ),

              SizedBox(height: 24.h),

              _sectionTitle(context, "حقوق المستخدم"),
              _sectionBody(
                context,
                "يحق لك طلب تعديل أو حذف بياناتك في أي وقت من خلال التواصل معنا عبر التطبيق.",
              ),

              SizedBox(height: 24.h),

              _sectionTitle(context, "التعديلات على السياسة"),
              _sectionBody(
                context,
                "قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سيتم إشعارك بأي تغييرات جوهرية داخل التطبيق.",
              ),

              SizedBox(height: 40.h),

              Center(
                child: Text(
                  "آخر تحديث: ${DateTime.now().year}",
                  style: context.typography.smMedium.copyWith(
                    color: AppColors.grayLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.typography.mdMedium.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontSize: 18.sp,
      ),
    );
  }

  Widget _sectionBody(BuildContext context, String body) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        body,
        style: context.typography.smMedium.copyWith(
          height: 1.6,
          color: AppColors.textDefault,
        ),
      ),
    );
  }
}
