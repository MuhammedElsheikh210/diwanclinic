import 'package:diwanclinic/Presentation/screens/shifts/list/shift_view.dart';
import '../../../../../index/index_main.dart';

class ClinicView extends StatefulWidget {
  final String? title;
  final String? doctorKey;

  const ClinicView({super.key, this.title, this.doctorKey});

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
        init: ClinicViewModel(doctorKey: widget.doctorKey),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,

            /// ================= APP BAR =================
            appBar: AppBar(
              title: Text(
                widget.title ?? "العيادات",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),

            /// ================= ADD CLINIC =================
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateClinicViewModel>();

                Get.to(
                  () => CreateClinicView(doctorKey: widget.doctorKey),
                  binding: Binding(),
                );
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),

            /// ================= BODY =================
            body:
                controller.listClinics == null
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
                              final user = Get.find<UserSession>().user?.user;
                              final String key =
                                  widget.doctorKey ??
                                  (user is AssistantUser
                                      ? user.doctorKey
                                      : user?.uid) ??
                                  (throw Exception("❌ doctorKey missing"));
                              print("doctod uid is $key");

                              Get.to(
                                () => ShiftView(
                                  clinic_key: clinic?.key ?? "",
                                  doctor_key: key,
                                ),
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
