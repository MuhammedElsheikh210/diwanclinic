import 'package:diwanclinic/Presentation/screens/patients/search/patient_search_view_model.dart';

import '../../../../index/index_main.dart';

class PatientSearchBar extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hint;
  final TextInputType? textInputType;
  final Function(LocalUser?, String) searchResult;
  final String tag;
  final FocusNode? focusNode;
  final VoidCallback? onCloseList; // ✅ new: hide list but don’t clear field

  const PatientSearchBar({
    super.key,
    required this.searchResult,
    required this.hint,
    this.textInputType,
    required this.textEditingController,
    required this.tag,
    this.focusNode,
    this.onCloseList,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientSearchViewModel>(
      init: PatientSearchViewModel(),
      tag: tag,
      builder: (controller) {

        final hasText = textEditingController.text.trim().isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.borderNeutralPrimary),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: const Icon(Icons.search, color: AppColors.grayMedium),
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  keyboardType: textInputType,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: context.typography.mdMedium.copyWith(
                      color: AppColors.grayMedium,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      controller.listPatients = null;
                      controller.update();
                    } else {
                      controller.getPatientsData(query: value);
                    }
                    searchResult(null, value);
                  },
                ),
              ),

              // ✅ X button to just close list, not clear text
              if (hasText)
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.grayMedium,
                    size: 22,
                  ),
                  splashRadius: 18,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    controller.listPatients = null;
                    controller.update();
                    if (onCloseList != null) onCloseList!();
                    // ❌ DO NOT clear text here
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class PatientResultList extends StatelessWidget {
  final String tag;
  final Function(LocalUser) onSelect;
  final VoidCallback? onCloseResults; // ✅ new

  const PatientResultList({
    super.key,
    required this.tag,
    required this.onSelect,
    this.onCloseResults,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientSearchViewModel>(
      tag: tag,
      builder: (controller) {
        final patients = controller.listPatients;
        if (patients == null || patients.isEmpty)
          return const SizedBox.shrink();

        final validPatients = patients.whereType<LocalUser>().toList();
        if (validPatients.isEmpty) return const SizedBox.shrink();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: validPatients.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: AppColors.borderNeutralPrimary.withOpacity(0.2),
          ),
          itemBuilder: (context, index) {
            final client = validPatients[index];

            return InkWell(
              onTap: () {
                onSelect(client);
                controller.listPatients = null;
                controller.update();
                FocusScope.of(context).unfocus();
                onCloseResults?.call(); // ✅ close search list
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: client.name ?? 'غير معروف',
                      textStyle: context.typography.mdBold,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: "${client.phone ?? ""} 📱",
                      textStyle: context.typography.mdMedium.copyWith(
                        color: AppColors.background_black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
