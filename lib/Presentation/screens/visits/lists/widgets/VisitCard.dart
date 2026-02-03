import '../../../../../index/index_main.dart';
import '../../visites_create/visites_create.dart';
import '../../visites_create/visites_creats_viewmodel.dart';

class VisitCard extends StatelessWidget {
  final VisitModel visitModel;
  final VisitViewModel controller;

  const VisitCard({
    Key? key,
    required this.visitModel,
    required this.controller,
  }) : super(key: key);

  bool get isDone => visitModel.status == 1;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.grayLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- Header Row (Name + Status) ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  visitModel.name ?? "بدون اسم",
                  style: typography.mdBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 16.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text("تمت الزيارة", style: typography.smRegular.copyWith()),
                  Checkbox(
                    value: isDone,
                    onChanged: (value) {
                      final updatedVisit = visitModel.copyWith(
                        status: value == true ? 1 : 0,
                      );
                      VisitService().updateVisitData(
                        visit: updatedVisit,
                        voidCallBack: (_) {
                          controller.getData();
                          Loader.showSuccess("تم تحديث حالة الزيارة");
                        },
                      );
                    },
                    activeColor: AppColors.primary,
                    side: const BorderSide(width: 1.2, color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8.h),
          Divider(height: 1, color: AppColors.grayLight.withOpacity(0.3)),
          SizedBox(height: 10.h),

          /// ---------- Contact Information ----------
          Row(
            children: [
              const Icon(Icons.phone, size: 18, color: Colors.green),
              SizedBox(width: 8.w),
              Text(
                visitModel.phone?.isNotEmpty == true
                    ? visitModel.phone!
                    : "بدون رقم",
                style: typography.smRegular.copyWith(),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.redAccent,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  visitModel.address?.isNotEmpty == true
                      ? visitModel.address!
                      : "بدون عنوان",
                  style: typography.smRegular.copyWith(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          /// ---------- Optional Comment ----------
          if (visitModel.comment?.isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Divider(height: 1, color: AppColors.grayLight.withOpacity(0.3)),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.comment_outlined,
                  size: 18,
                  color: Colors.blueAccent,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    visitModel.comment ?? "",
                    style: typography.smRegular.copyWith(),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 10.h),

          /// ---------- Action Buttons ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.blueAccent,
                tooltip: "تعديل",
                onTap: () {
                  Get.delete<CreateVisitViewModel>();
                  showCustomBottomSheet(
                    context: context,
                    child: CreateVisitView(visitModel: visitModel),
                  );
                },
              ),
              SizedBox(width: 6.w),
              _buildActionButton(
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                tooltip: "حذف",
                onTap: () => _showConfirmDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Reusable rounded icon button
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  /// ✅ Confirm dialog
  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("حذف الزيارة"),
        content: const Text("هل أنت متأكد أنك تريد حذف هذه الزيارة؟"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteVisit(visitModel);
              Loader.showSuccess("تم حذف الزيارة");
            },
            child: const Text(
              "تأكيد",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
