import 'package:diwanclinic/Presentation/screens/shifts/list/shift_view.dart';

import '../../../../../index/index_main.dart';

class ClinicView extends StatefulWidget {
  final String? title;

  const ClinicView({super.key, this.title});

  @override
  State<ClinicView> createState() => _ClinicViewState();
}

class _ClinicViewState extends State<ClinicView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<ClinicViewModel>(
        init: ClinicViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text(
                widget.title ?? "العيادات",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateClinicViewModel>();
                Get.toNamed(createClinicView);
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body: controller.listClinics == null
                ? const ShimmerLoader()
                : controller.listClinics!.isEmpty
                ? const NoDataWidget()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 5.w,
                    ),
                    itemCount: controller.listClinics!.length,
                    itemBuilder: (context, index) {
                      final clinic = controller.listClinics![index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.h,
                          horizontal: 10.w,
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(
                              () => ShiftView(clinic_key: clinic?.key ?? ""),
                              binding: Binding(),
                            );
                          },
                          child: ClinicCard(
                            clinic: clinic ?? ClinicModel(),
                            controller: controller,
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
