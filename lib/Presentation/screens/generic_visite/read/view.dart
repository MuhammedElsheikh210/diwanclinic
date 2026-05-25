import 'package:diwanclinic/Presentation/screens/generic_visite/create_update/create_view.dart';
import 'package:diwanclinic/Presentation/screens/generic_visite/create_update/create_visit_view_model.dart';

import '../../../../../index/index_main.dart';

class VisitGenericView extends StatefulWidget {
  final String? title;

  const VisitGenericView({super.key, this.title});

  @override
  State<VisitGenericView> createState() => _VisitGenericViewState();
}

class _VisitGenericViewState extends State<VisitGenericView> {
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
                Get.delete<CreateVisitModel>();

                showCustomBottomSheet(
                  context: context,

                  child: const CreateVisitGenericView(),
                );
              },

              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),

            body:
                controller.listVisits == null
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
                            visit: visit ?? const VisitModel(),

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
