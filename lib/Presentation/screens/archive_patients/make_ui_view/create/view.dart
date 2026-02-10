import 'package:diwanclinic/Presentation/screens/archive_patients/make_ui_view/create_archive_field_screen.dart';
import '../../../../../index/index_main.dart';

class CreateArchiveFormView extends StatefulWidget {
  const CreateArchiveFormView({Key? key}) : super(key: key);

  @override
  State<CreateArchiveFormView> createState() => _CreateArchiveFormViewState();
}

class _CreateArchiveFormViewState extends State<CreateArchiveFormView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyForm = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initController(() => CreateArchiveFormViewModel());
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateArchiveFormView', 1);

    return GetBuilder<CreateArchiveFormViewModel>(
      builder: (controller) {
        /// ⏳ Loading State
        if (controller.isLoading) {
          /// ⏳ Professional Loading State
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Loader
                  const SizedBox(
                    height: 48,
                    width: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// Title
                  Text("جاري التحميل", style: context.typography.mdBold),

                  SizedBox(height: 6.h),

                  /// Subtitle
                  Text(
                    "يرجى الانتظار قليلًا",
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.white,

          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(
              controller.isUpdate ? "تعديل فورم الأرشيف" : "إعداد فورم الأرشيف",
              style: context.typography.lgBold.copyWith(color: AppColors.white),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.white),
          ),

          /// 💾 Save Button
          bottomNavigationBar: SafeArea(
            top: false,
            child: SizedBox(
              height: 80.h,
              child: BottomNavigationActions(
                rightTitle: controller.isUpdate ? "تحديث" : "حفظ",
                rightAction: controller.saveForm,
                isRightEnabled: controller.validateForm(),
              ),
            ),
          ),

          /// ➕ Add Field
          floatingActionButton: InkWell(
            onTap: () async {
              final field = await showModalBottomSheet<ArchiveFieldModel>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => const CreateArchiveFieldScreen(),
              );

              if (field != null) {
                controller.addField(field);
              }
            },
            child: const Svgicon(icon: IconsConstants.fab_Button),
          ),

          body: Form(
            key: globalKeyForm,
            child: KeyboardActions(
              config: keyboardService.buildConfig(context, keys),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                children: [
                  /// 🟡 Empty State (Professional)
                  if (controller.fields.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Icon / Illustration
                          Container(
                            height: 80.h,
                            width: 80.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.article_outlined,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),

                          SizedBox(height: 16.h),

                          /// Title
                          Text(
                            "لا توجد حقول بعد",
                            style: context.typography.lgBold,
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 6.h),

                          /// Description
                          Text(
                            "ابدأ بإنشاء الحقول التي سيتم إدخالها\nعند تسجيل بيانات المريض",
                            style: context.typography.smRegular.copyWith(
                              color: AppColors.textSecondaryParagraph,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 20.h),

                          /// CTA Button
                          SizedBox(
                            height: 44.h,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final field =
                                    await showModalBottomSheet<
                                      ArchiveFieldModel
                                    >(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (_) =>
                                          const CreateArchiveFieldScreen(),
                                    );

                                if (field != null) {
                                  controller.addField(field);
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("إضافة أول حقل"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// 🧩 Fields List
                  ...controller.fields.asMap().entries.map((entry) {
                    final index = entry.key;
                    final field = entry.value;

                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.borderNeutralPrimary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          field.key,
                          style: context.typography.mdMedium,
                        ),
                        subtitle: Text(
                          field.type == ArchiveFieldType.text ? "نص" : "رقم",
                        ),
                        trailing: InkWell(
                          onTap: () => controller.removeField(index),
                          child: const Svgicon(
                            icon: IconsConstants.delete_btn,
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
