import 'package:diwanclinic/Global/Constatnts/animations.dart';
import 'package:diwanclinic/Presentation/Widgets/no_data_animated.dart';
import 'package:diwanclinic/Presentation/screens/incomes_doctors/income_doctor_view_model.dart';
import 'package:diwanclinic/Presentation/screens/incomes_doctors/widgets/income_app_bar.dart';
import 'package:diwanclinic/Presentation/screens/incomes_doctors/widgets/income_doctor_card.dart';
import 'package:diwanclinic/Presentation/screens/incomes_doctors/widgets/income_widget.dart';
import '../../../../../index/index_main.dart';

class IncomeView extends StatelessWidget {
  const IncomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IncomeViewModel>(
      init: IncomeViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: IncomeAppBar(controller: controller),

          body: controller.todayReservations.isEmpty
              ? const NoDataAnimated(
                  title: "لا توجد إيرادات اليوم",
                  subtitle: "",
                  lottiePath: Animations.money,
                  height: 200,
                )
              : ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  children: [
                    /// 🔵 تقرير اليوم (زي المساعد)
                    IncomeDailyReportWidget(controller: controller),

                    SizedBox(height: 18.h),

                    /// 🧾 قائمة الحجوزات
                    ...controller.todayReservations
                        .map((res) => IncomeCard(reservation: res))
                        .toList(),

                    SizedBox(height: 12.h),
                  ],
                ),
        );
      },
    );
  }
}
