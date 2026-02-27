import 'package:diwanclinic/Presentation/screens/sales_app/target_sales_dashboard/sales_target_controller.dart';
import 'package:diwanclinic/index/index_main.dart';
import 'package:flutter/material.dart';

class TargetDashboardScreen extends StatelessWidget {
  const TargetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // 🔥 يخلي كل الشاشة عربي
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),

        /// 🔵 APP BAR
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Column(
            children: [
              Text("التارجت الشهري", style: context.typography.lgBold),
            ],
          ),
        ),

        body: SafeArea(
          child: GetBuilder<SalesTargetController>(
            init: SalesTargetController(),
            builder: (controller) {
              final percent = controller.percentage;

              return Column(
                children: [
                  const SizedBox(height: 24),

                  /// 🔵 CLEAN TARGET CARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: ScreenUtil().screenWidth - 50.w,
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// 🔵 Animated Progress Ring
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: percent),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 140,
                                    width: 140,
                                    child: CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${controller.completedCount}",
                                        style: context.typography.xlBold
                                            .copyWith(
                                              fontSize: 34,
                                              color: AppColors.primary,
                                            ),
                                      ),
                                      Text(
                                        "من ${controller.monthlyTarget}",
                                        style: context.typography.smRegular
                                            .copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          Text(
                            "تم تحقيق ${(percent * 100).toStringAsFixed(0)}٪",
                            style: context.typography.mdMedium.copyWith(
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            controller.remaining > 0
                                ? "متبقي ${controller.remaining} طبيب"
                                : "تم تحقيق التارجت 🎉",
                            style: context.typography.smRegular.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 🔵 قائمة الدكاترة
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "الدكاترة المحققين للتارجت",
                        style: context.typography.mdBold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.completedDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = controller.completedDoctors[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.name ?? "",
                                      style: context.typography.mdBold,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor.specialization ?? "",
                                      style: context.typography.smRegular,
                                    ),
                                  ],
                                ),
                              ),

                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xffE6EEFF),
                                child: Text(
                                  doctor.name != null && doctor.name!.isNotEmpty
                                      ? doctor.name![0]
                                      : "د",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff5B8DEF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
