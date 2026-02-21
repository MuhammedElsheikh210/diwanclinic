import 'package:diwanclinic/Presentation/screens/doctors/list/doctor_view.dart';
import 'package:diwanclinic/index/index_main.dart';

class SpecializationSectionView extends StatelessWidget {
  final HomePatientController controller;

  const SpecializationSectionView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final list = controller.listCategories ?? [];

    /// 🔥 Show only 6 items max
    final int itemCount = list.length >= 6 ? 6 : list.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderSectionWidget(
          title: "التخصصات",
          onMore: () => Get.to(() => const SpecializationView()),
        ),

        SizedBox(height: 14.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 4, left: 0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.91.h,
            ),
            itemCount: itemCount,
            itemBuilder: (_, i) {
              final c = list[i];
              if (c == null) return const SizedBox.shrink();

              return InkWell(
                onTap: () {
                  Get.to(
                    () => DoctorView(
                      specializeKey: c.key ?? "",
                      specializeName: c.name ?? "",
                    ),
                  );
                },
                child: SpecializeCard(
                  categoryEntity: c,
                  showAdminActions: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
