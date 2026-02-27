import 'package:diwanclinic/Presentation/Widgets/time_widget.dart';

import '../../../../../index/index_main.dart';
import 'package:intl/intl.dart';

class CreateVisitView extends StatefulWidget {
  final DoctorListModel doctor;

  const CreateVisitView({Key? key, required this.doctor}) : super(key: key);

  @override
  State<CreateVisitView> createState() => _CreateVisitViewState();
}

class _CreateVisitViewState extends State<CreateVisitView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyVisit = GlobalKey<FormState>();

  late final CreateVisitViewModel controller;

  @override
  void initState() {
    super.initState();

    controller = initController(() => CreateVisitViewModel());

    controller.initFromDoctor(widget.doctor);
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateVisitView', 2);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GetBuilder<CreateVisitViewModel>(
          builder: (_) {
            return Column(
              children: [
                /// 🔵 HEADER
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "إنشاء زيارة",
                        style: context.typography.lgBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                /// BODY
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ListView(
                      children: [
                        _buildDoctorCard(context),

                        SizedBox(height: 30.h),

                        /// 📅 DATE
                        _buildSectionTitle(context, "تاريخ الزيارة"),
                        SizedBox(height: 8.h),

                        CalenderWidget(
                          hintText: "اختر التاريخ",
                          initialTimestamp:
                              controller.visitTimestamp ??
                              DateTime.now().millisecondsSinceEpoch,
                          onDateSelected: (timeStamp, date) {
                            final pickedDate =
                                DateTime.fromMillisecondsSinceEpoch(
                                  timeStamp.millisecondsSinceEpoch,
                                );

                            controller.onSelectDate(pickedDate);
                          },
                        ),

                        SizedBox(height: 24.h),

                        /// ⏰ TIME
                        _buildSectionTitle(context, "وقت الزيارة"),
                        SizedBox(height: 8.h),

                        TimeWidget(
                          hintText: "اختر الوقت",
                          initialTimestamp: controller.visitTimestamp,
                          onTimeSelected: (dateTime, formatted) {
                            controller.updateTime(
                              TimeOfDay.fromDateTime(dateTime),
                            );
                          },
                        ),

                        SizedBox(height: 24.h),

                        /// 📝 NOTES
                        _buildSectionTitle(context, "ملاحظات"),
                        SizedBox(height: 8.h),

                        CustomInputField(
                          padding_horizontal: 0,
                          hintText: "أضف ملاحظة إن وجدت",
                          controller: controller.commentController,
                          label: '',
                          keyboardType: TextInputType.text,
                          focusNode: FocusNode(),
                          validator: (String? p1) {},
                        ),

                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      /// 🔵 BOTTOM BUTTON
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        child: GetBuilder<CreateVisitViewModel>(
          builder: (_) {
            return PrimaryTextButton(
              appButtonSize: AppButtonSize.xxLarge,
              onTap: controller.validateStep() ? controller.saveVisit : null,
              label: AppText(
                text: "إنشاء الزيارة",
                textStyle: context.typography.mdMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              widget.doctor.name![0],
              style: context.typography.lgBold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name ?? "",
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        SpecializationMapper.getLabel(
                          widget.doctor.specialization,
                        ),
                        style: context.typography.smRegular,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Class ${widget.doctor.doctorClass}",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        title,
        style: context.typography.mdMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
