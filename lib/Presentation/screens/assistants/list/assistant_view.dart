import '../../../../../index/index_main.dart';

class AssistantView extends StatefulWidget {
  final String? title;
  final String? doctor_uid;
  final LocalUser? doctorUser;

  const AssistantView({
    super.key,
    this.title,
    this.doctor_uid,
    this.doctorUser,
  });

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  late final AssistantViewModel controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = initController(() => AssistantViewModel());
    controller.doctorUid = widget.doctor_uid;
    controller.getData(doctor_uid: widget.doctor_uid ?? "");
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<AssistantViewModel>(
        init: AssistantViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text(
                widget.title ?? "المساعدين",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateAssistantViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: CreateAssistantView(
                    doctor_uid: widget.doctor_uid ?? "",
                    doctorUser: widget.doctorUser,
                  ),
                );
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body:
                controller.listAssistants == null
                    ? const ShimmerLoader()
                    : controller.listAssistants!.isEmpty
                    ? const NoDataWidget()
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.h,
                        horizontal: 5.w,
                      ),
                      itemCount: controller.listAssistants!.length,
                      itemBuilder: (context, index) {
                        final assistant = controller.listAssistants![index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.h,
                            horizontal: 10.w,
                          ),
                          child: AssistantCard(
                            assistant: assistant,
                            controller: controller,
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
