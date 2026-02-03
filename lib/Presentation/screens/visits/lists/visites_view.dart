
import 'package:diwanclinic/Presentation/screens/visits/lists/widgets/VisitCard.dart';
import 'package:diwanclinic/Presentation/screens/visits/visites_create/visites_create.dart';
import 'package:diwanclinic/Presentation/screens/visits/visites_create/visites_creats_viewmodel.dart';

import '../../../../../index/index_main.dart';

class VisitView extends StatefulWidget {
  final String? title;

  const VisitView({super.key, this.title});

  @override
  State<VisitView> createState() => _VisitViewState();
}

class _VisitViewState extends State<VisitView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<VisitViewModel>(
        init: VisitViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorMappingImpl().white,
            appBar: AppBar(
              title: Text(
                widget.title ?? "الزيارات",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateVisitViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: const CreateVisitView(),
                );
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body: controller.listVisits == null
                ? const ShimmerLoader()
                : controller.listVisits!.isEmpty
                ? const NoDataWidget()
                : ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: 15.h,
                horizontal: 5.w,
              ),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.listVisits!.length,
              itemBuilder: (BuildContext context, int index) {
                final visit = controller.listVisits![index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: 10.0.w,
                    right: 10.0.w,
                    bottom: 5.h,
                  ),
                  child: VisitCard(
                    visitModel: visit ?? const VisitModel(),
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
