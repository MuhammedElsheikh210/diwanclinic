import 'package:diwanclinic/Presentation/screens/sales_app/doctor_list/read/widgets/filter_bottomsheet.dart';

import '../../../../../index/index_main.dart';

class DoctorListView extends StatelessWidget {
  const DoctorListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorListViewModel>(
      init: DoctorListViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: Text("قائمة الدكاترة", style: context.typography.lgBold),
          ),
          floatingActionButton: InkWell(
            onTap: () {
              showCustomBottomSheet(
                context: context,
                heightFactor: 0.9,
                child: const CreateDoctorListView(),
              );
            },
            child: const Svgicon(icon: IconsConstants.fab_Button),
          ),
          body: controller.listDoctors == null
              ? const ShimmerLoader()
              : Column(
                  children: [


                    /// 🔵 HEADER ROW (Total + Filter)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          /// 🟢 TOTAL DOCTORS BADGE
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(
                                        0.15,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.people_alt_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "إجمالي الدكاترة",
                                        style: context.typography.xsRegular
                                            .copyWith(color: Colors.grey),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        "${controller.totalDoctors}",
                                        style: context.typography.lgBold
                                            .copyWith(color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: 12.w),

                          /// 🔵 FILTER BUTTON
                          InkWell(
                            borderRadius: BorderRadius.circular(16.r),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) =>
                                    FilterBottomSheet(controller: controller),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 18.w,
                                vertical: 16.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.tune_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "فلترة",
                                    style: context.typography.smMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 LIST
                    Expanded(
                      child: controller.filteredDoctors.isEmpty
                          ? const NoDataWidget()
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: controller.filteredDoctors.length,
                              itemBuilder: (context, index) {
                                final doctor =
                                    controller.filteredDoctors[index];

                                return InkWell(
                                  onTap: () {
                                    /// نحذف أي ViewModel قديم عشان ما يحصلش data retention
                                    Get.delete<CreateVisitViewModel>();

                                    showCustomBottomSheet(
                                      context: context,
                                      heightFactor: 0.9,
                                      child: CreateVisitView(doctor: doctor),
                                    );
                                  },
                                  child: DoctorListCard(
                                    doctor: doctor,
                                    controller: controller,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
