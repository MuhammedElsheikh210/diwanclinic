import '../../../../../../index/index_main.dart';

class VisitDetailsPage extends StatefulWidget {
  final VisitModel visit;

  const VisitDetailsPage({super.key, required this.visit});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  late final VisitDetailsViewModel controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = initController(() => VisitDetailsViewModel());
    controller.init(widget.visit);
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VisitDetailsViewModel>(
      init: controller,
      global: false, // مهم جدًا
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: const Text("تفاصيل الزيارة"),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      /// 🔹 Header
                      VisitHeaderSection(visit: controller.currentVisit),

                      const SizedBox(height: 20),

                      /// 🔹 Sales Status
                      VisitSalesSection(controller: controller),

                      const SizedBox(height: 20),

                      /// 🔹 Steps
                      VisitStepsSection(controller: controller),
                    ],
                  ),
                ),

                /// 🔥 Save Button (ثابت تحت)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(.05),
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryTextButton(
                      appButtonSize: AppButtonSize.xxLarge,
                      label: AppText(
                        text: "حفظ التعديلات",
                        textStyle: context.typography.mdMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        controller.save();

                        /// رجّع الريزلت علشان الكارت يتحدث
                        Get.back(result: true);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
