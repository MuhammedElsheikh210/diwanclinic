import 'package:diwanclinic/index/index_main.dart';

class CreateAnnouncementBottomSheet extends StatefulWidget {
  const CreateAnnouncementBottomSheet({super.key});

  @override
  State<CreateAnnouncementBottomSheet> createState() =>
      _CreateAnnouncementBottomSheetState();
}

class _CreateAnnouncementBottomSheetState
    extends State<CreateAnnouncementBottomSheet> {
  DoctorAnnouncementType? _selectedType;
  final _reasonController = TextEditingController();
  final _estimatedTimeController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorAnnouncementController>(
      builder: (controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'إعلان عن حالة الدكتور',
                style: context.typography.lgBold.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'اختار نوع الإعلان وسيتم إعلام المرضى فوراً',
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),

              const SizedBox(height: 20),

              // Type selector
              _buildTypeGrid(context),

              // Reason field (shown conditionally)
              if (_selectedType?.requiresReason == true) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _reasonController,
                  label: 'السبب (اختياري)',
                  hint: _reasonHint(_selectedType),
                  maxLines: 2,
                ),
              ],

              // Estimated time (shown for delayed)
              if (_selectedType == DoctorAnnouncementType.delayed) ...[
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _estimatedTimeController,
                  label: 'وقت الوصول المتوقع (اختياري)',
                  hint: 'مثال: 10:30 صباحاً',
                  keyboardType: TextInputType.text,
                ),
              ],

              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      (_selectedType == null || controller.isCreating)
                          ? null
                          : () => _submit(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedType?.color ?? AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      controller.isCreating
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            _selectedType == null
                                ? 'اختر نوع الإعلان أولاً'
                                : 'إرسال الإعلان',
                            style: context.typography.mdMedium.copyWith(
                              color:
                                  _selectedType == null
                                      ? Colors.grey
                                      : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeGrid(BuildContext context) {
    final types = DoctorAnnouncementType.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = _selectedType == type;
        final color = type.color;

        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? color.withValues(alpha: 0.12)
                      : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  type.icon,
                  color: isSelected ? color : Colors.grey.shade500,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type.arabicLabel,
                    style: context.typography.smMedium.copyWith(
                      color:
                          isSelected ? color : AppColors.textSecondaryParagraph,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.multiline,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.smMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _selectedType?.color ?? AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _reasonHint(DoctorAnnouncementType? type) {
    switch (type) {
      case DoctorAnnouncementType.delayed:
        return 'مثال: ضغط المرور في الطريق';
      case DoctorAnnouncementType.cancelledToday:
        return 'مثال: ظروف طارئة';
      case DoctorAnnouncementType.temporaryBreak:
        return 'مثال: حالة ولادة طارئة — سيرجع خلال ساعة';
      default:
        return 'أكتب السبب هنا...';
    }
  }

  Future<void> _submit(DoctorAnnouncementController controller) async {
    if (_selectedType == null) return;

    final sessionUser = Get.find<UserSession>().user?.user;
    String? doctorKey;
    String doctorName = '';

    if (sessionUser is DoctorUser) {
      doctorKey = sessionUser.uid;
      doctorName = sessionUser.name ?? '';
    } else if (sessionUser is AssistantUser) {
      doctorKey = sessionUser.doctorKey;
      doctorName = ''; // assistant doesn't know doctor name directly
    }

    if (doctorKey == null) {
      Loader.showError('تعذر تحديد الدكتور');
      return;
    }

    final success = await controller.createAnnouncement(
      type: _selectedType!,
      doctorKey: doctorKey,
      doctorName: doctorName,
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
      estimatedTime: _estimatedTimeController.text.trim().isEmpty
          ? null
          : _estimatedTimeController.text.trim(),
    );

    if (success) {
      Get.back();
      Loader.showSuccess('تم إرسال الإعلان ✅');
    } else {
      Loader.showError('حدث خطأ أثناء الإرسال');
    }
  }
}
