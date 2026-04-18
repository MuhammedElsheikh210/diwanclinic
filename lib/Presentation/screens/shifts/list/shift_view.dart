import '../../../../../index/index_main.dart';

class ShiftView extends StatefulWidget {
  final String? title;
  final String clinic_key;
  final String doctor_key;

  const ShiftView({
    super.key,
    this.title,
    required this.clinic_key,
    required this.doctor_key,
  });

  @override
  State<ShiftView> createState() => _ShiftViewState();
}

class _ShiftViewState extends State<ShiftView> {
  @override
  void initState() {
    ShiftViewModel shiftViewModel = initController(() => ShiftViewModel());
    shiftViewModel.clinic_key = widget.clinic_key;
    shiftViewModel.doctor_key = widget.doctor_key;
    
    shiftViewModel.getData();
    shiftViewModel.update();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<ShiftViewModel>(
        init: ShiftViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text(
                widget.title ?? "مواعيد الشفتات",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateShiftViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: CreateShiftView(
                    clinic_key: widget.clinic_key,
                    doctor_key: widget.doctor_key,
                  ),
                );
              },

              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body:
                controller.listShifts == null
                    ? const ShimmerLoader()
                    : controller.listShifts!.isEmpty
                    ? const NoDataWidget()
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.h,
                        horizontal: 5.w,
                      ),
                      itemCount: controller.listShifts!.length,
                      itemBuilder: (context, index) {
                        final shift = controller.listShifts![index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.h,
                            horizontal: 10.w,
                          ),
                          child: ShiftCard(
                            shift: shift ?? ShiftModel(),
                            doctor_key: widget.doctor_key,
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
