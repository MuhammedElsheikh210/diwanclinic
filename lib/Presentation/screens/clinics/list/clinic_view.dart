import 'package:diwanclinic/Presentation/screens/shifts/list/shift_view.dart';
import '../../../../../index/index_main.dart';

class ClinicView extends StatefulWidget {
  final String? title;
  final String? doctorKey;
  final LocalUser? doctorUser;

  const ClinicView({super.key, this.title, this.doctorKey, this.doctorUser});

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
          final hasClinics =
              controller.listClinics != null &&
              controller.listClinics!.isNotEmpty;

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

            /// ================= FLOATING BUTTON =================
            floatingActionButton:
                hasClinics
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// ➕ Add Assistant
                        FloatingActionButton.extended(
                          heroTag: "add_assistant",
                          backgroundColor: AppColors.primary,
                          onPressed: () {
                            Get.to(
                              () => AssistantView(
                                doctor_uid: widget.doctorKey,
                                doctorUser: widget.doctorUser,
                              ),
                              binding: Binding(),
                            );
                          },
                          label: Text(
                            "إضافة مساعدين",
                            style: context.typography.mdBold.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        /// ➕ Add Clinic
                        FloatingActionButton(
                          heroTag: "add_clinic",
                          onPressed: () {
                            Get.delete<CreateClinicViewModel>();

                            Get.to(
                              () =>
                                  CreateClinicView(doctorKey: widget.doctorKey),
                              binding: Binding(),
                            );
                          },
                          child: const Icon(Icons.add),
                        ),
                      ],
                    )
                    : FloatingActionButton(
                      onPressed: () {
                        Get.delete<CreateClinicViewModel>();

                        Get.to(
                          () => CreateClinicView(doctorKey: widget.doctorKey),
                          binding: Binding(),
                        );
                      },
                      child: const Icon(Icons.add),
                    ),

            /// ================= BODY =================
            body:
                controller.listClinics == null
                    ? const ShimmerLoader()
                    : controller.listClinics!.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const NoDataWidget(),
                        SizedBox(height: 20.h),
                        Text(
                          "لازم تضيف عيادة الأول علشان تقدر تضيف مساعدين",
                          style: context.typography.mdRegular,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
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
