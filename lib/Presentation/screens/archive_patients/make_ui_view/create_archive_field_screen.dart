import '../../../../index/index_main.dart';

class CreateArchiveFieldScreen extends StatefulWidget {
  const CreateArchiveFieldScreen({Key? key}) : super(key: key);

  @override
  State<CreateArchiveFieldScreen> createState() =>
      _CreateArchiveFieldScreenState();
}

class _CreateArchiveFieldScreenState extends State<CreateArchiveFieldScreen> {
  final TextEditingController _titleController = TextEditingController();
  ArchiveFieldType? selectedArchiveType;

  bool get isValid =>
      _titleController.text.trim().isNotEmpty && selectedArchiveType != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Drag Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.borderNeutralPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            /// 🔹 Title
            Center(
              child: Text("إضافة حقل جديد", style: context.typography.lgBold),
            ),

            SizedBox(height: 20.h),

            /// 🔹 Field Type
            Text("نوع الحقل", style: context.typography.smMedium),
            SizedBox(height: 8.h),

            DropdownButtonFormField<ArchiveFieldType>(
              value: selectedArchiveType,
              hint: const Text("اختر نوع البيانات"),
              items: const [
                DropdownMenuItem(
                  value: ArchiveFieldType.text,
                  child: Text("نص"),
                ),
                DropdownMenuItem(
                  value: ArchiveFieldType.number,
                  child: Text("رقم"),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedArchiveType = value);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.grayLight.withValues(alpha: 0.2),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppColors.borderNeutralPrimary),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            /// 🔹 Field Name
            CustomInputField(
              label: "اسم الحقل",
              controller: _titleController,
              hintText: "مثال: الاسم، السن، الوزن",
              keyboardType: TextInputType.text,
              voidCallbackAction: (_) => setState(() {}),
              focusNode: FocusNode(),
              validator: (String? p1) {},
            ),

            SizedBox(height: 6.h),

            Text(
              "سيظهر هذا الحقل عند إدخال بيانات المريض",
              style: context.typography.xsRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),

            SizedBox(height: 24.h),

            /// 🔹 Action Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: isValid ? _onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "إضافة الحقل",
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onConfirm() {
    final field = ArchiveFieldModel(
      key: _titleController.text.trim(),
      type: selectedArchiveType!,
    );

    Navigator.pop(context, field);
  }
}
