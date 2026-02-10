import '../../../../index/index_main.dart';

class CreateArchivePatientViewModel extends GetxController {
  ArchiveFormModel? form;
  ArchivePatientModel? currentArchive;

  bool isUpdate = false;
  bool isLoading = true;

  final Map<String, TextEditingController> fieldControllers = {};

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadForm();
  }

  /// ================= LOAD FORM ONLY =================
  void loadForm({ArchivePatientModel? archive}) {
    ArchiveFormService().getArchiveFormsData(
      data: {},
      voidCallBack: (forms) {
        if (forms.isNotEmpty) {
          form = forms.first; // index 0 دايمًا

          if (archive != null) {
            initEdit(archive);
          } else {
            initCreate(patientId: "patientId");
          }
        }

        update();
      },
    );
  }

  /// ================= INIT CREATE =================
  void initCreate({required String patientId}) {
    currentArchive = ArchivePatientModel(
      id: "",
      patientId: patientId,
      formId: form!.id,
      data: {},
      createdAt: DateTime.now().toIso8601String(),
    );

    _initControllers();
    isUpdate = false;
    update();
  }

  /// ================= INIT EDIT =================
  void initEdit(ArchivePatientModel archive) {
    currentArchive = archive;
    _initControllers(initialValues: archive.data);
    isUpdate = true;
    update();
  }

  /// ================= CONTROLLERS =================
  void _initControllers({Map<String, dynamic>? initialValues}) {
    fieldControllers.clear();

    for (final field in form!.fields) {
      fieldControllers[field.key] = TextEditingController(
        text: initialValues?[field.key]?.toString() ?? "",
      );
    }
  }

  /// ================= UPDATE VALUE =================
  void updateValue(String key, dynamic value) {
    currentArchive!.data[key] = value;
  }

  /// ================= SAVE =================
  void save() {
    final service = ArchivePatientService();

    isUpdate
        ? service.updateArchivePatientData(
            archiveId: currentArchive!.id,
            archivePatient: currentArchive!,
            voidCallBack: (_) {
              ArchivePatientViewModel archivePatientViewModel = initController(
                () => ArchivePatientViewModel(),
              );
              archivePatientViewModel.getData();
              archivePatientViewModel.update();
            },
          )
        : service.createArchivePatientData(
            archivePatient: currentArchive!,
            voidCallBack: (_) {
              ArchivePatientViewModel archivePatientViewModel = initController(()=> ArchivePatientViewModel());
              archivePatientViewModel.getData();
              archivePatientViewModel.update();
            },
          );
  }
}
