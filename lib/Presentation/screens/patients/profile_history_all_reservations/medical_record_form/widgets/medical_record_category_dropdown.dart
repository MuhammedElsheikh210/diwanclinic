/// medical_record_category_dropdown.dart

import '../../../../../../index/index_main.dart';

class MedicalRecordCategoryDropdown extends StatelessWidget {
  final PatientProfileAllHistoryViewModel vm;

  const MedicalRecordCategoryDropdown({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return GenericDropdown<GenericListModel>(
      hint_text: "اختر التصنيف",

      title: "التصنيف",

      items:
          vm.medicalCategories
              .map((e) => GenericListModel(key: e?.key, name: e?.name))
              .toList(),

      initialValue:
          vm.selectedCategory == null
              ? null
              : GenericListModel(
                key: vm.selectedCategory?.key,
                name: vm.selectedCategory?.name,
              ),

      onChanged: (val) async {
        final selected = vm.medicalCategories.firstWhereOrNull(
          (e) => e?.key == val.key,
        );

        await vm.onSelectCategory(selected);
      },

      displayItemBuilder:
          (item) => Text(
            item.name ?? "",
            style: context.typography.mdRegular.copyWith(
              color: ColorMappingImpl().textLabel,
            ),
          ),
    );
  }
}
