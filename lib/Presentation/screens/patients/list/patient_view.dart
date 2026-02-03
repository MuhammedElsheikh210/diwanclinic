import 'package:diwanclinic/Presentation/screens/chat/chat_details/chat_view.dart';

import '../../../../../index/index_main.dart';

class PatientView extends StatefulWidget {
  final String? title;

  const PatientView({super.key, this.title});

  @override
  State<PatientView> createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<PatientViewModel>(
        init: PatientViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text(
                widget.title ?? "المرضى",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreatePatientViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: const CreatePatientView(),
                );
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body: controller.listPatients == null
                ? const ShimmerLoader()
                : controller.listPatients!.isEmpty
                ? const NoDataWidget()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 5.w,
                    ),
                    itemCount: controller.listPatients!.length,
                    itemBuilder: (context, index) {
                      final patient = controller.listPatients![index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.h,
                          horizontal: 10.w,
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(
                              () => ChatView(
                                receiverId: patient?.key ?? "",
                                receiverName: patient?.name ?? "",
                              ),binding: Binding()
                            );
                          },
                          child: PatientCard(
                            patient: patient ?? PatientModel(),
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
