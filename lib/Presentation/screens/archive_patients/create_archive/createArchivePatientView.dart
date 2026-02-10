import '../../../../../index/index_main.dart';

class CreateArchivePatientView extends StatelessWidget {
  final ArchivePatientModel? archive;

  const CreateArchivePatientView({super.key, this.archive});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateArchivePatientViewModel>(
      init: CreateArchivePatientViewModel(),
      builder: (controller) {
        if (controller.form == null) {
          return const Scaffold(
            body: Center(child: Text("لا يوجد فورم أرشيف")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              controller.isUpdate ? "تعديل أرشيف المريض" : "إضافة أرشيف جديد",
            ),
          ),

          bottomNavigationBar: SizedBox(
            height: 100,
            child: BottomNavigationActions(
              rightTitle: controller.isUpdate ? "تحديث" : "حفظ",
              rightAction: controller.save,
              isRightEnabled: true,
            ),
          ),

          body: controller.form == null || controller.fieldControllers.isEmpty
              ? Container(height: 200, color: Colors.red)
              : ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  children: controller.form!.fields.map((field) {
                    final textController =
                        controller.fieldControllers[field.key]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomInputField(
                        label: field.key,
                        controller: textController,
                        keyboardType: field.type == ArchiveFieldType.number
                            ? TextInputType.number
                            : TextInputType.text,
                        hintText: "أدخل ${field.key}",
                        voidCallbackAction: (val) {
                          controller.updateValue(field.key, val);
                        },
                        validator: InputValidators.combine([notEmptyValidator]),
                        focusNode: FocusNode(),
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }
}
