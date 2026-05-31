/// medical_record_image_picker.dart

import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../../../../index/index_main.dart';

class MedicalRecordImagePicker extends StatelessWidget {
  final PatientProfileAllHistoryViewModel vm;

  const MedicalRecordImagePicker({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();

            final images = await picker.pickMultiImage();

            if (images.isNotEmpty) {
              vm.selectedImages.addAll(images);

              vm.update();
            }
          },

          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColors.primary.withValues(alpha: 0.04),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "رفع صور أو ملفات",
                  style: context.typography.smMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (vm.selectedImages.isNotEmpty) ...[
          SizedBox(height: 16.h),

          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,

            children: List.generate(
              vm.selectedImages.length,
                  (index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),

                  child: Image.file(
                    File(vm.selectedImages[index].path),

                    width: 90.w,
                    height: 90.w,

                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}