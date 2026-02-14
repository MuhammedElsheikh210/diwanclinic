import '../../../../../../index/index_main.dart';

class ReservationViewModel extends GetxController {
  // Managers
  late final ReservationSyncService syncService;
  late final ReservationQueueManager queueManager;
  late final ReservationFilterManager filterManager;
  late final ReservationActionManager actionManager;
  late final ReservationQueryManager queryManager;

  // Services
  final PrescriptionUploadService prescriptionService =
      PrescriptionUploadService();

  // UI State
  bool showDailyReport = false;
  bool? fromUpdate;
  bool isSyncing = false;
  bool _isInitialLoad = true;

  int selectedTab = 0;
  int completedReservation = 0;

  // Date + Patient
  String? appointmentDate;
  String? selectedPatientLastVisit;
  num? create_at;

  // Reservation Data
  List<ReservationModel?>? listReservations;
  List<ReservationModel> completeDayReservations = [];

  // Clinic + Shift
  List<ClinicModel?>? listClinic;
  List<GenericListModel>? clinicDropdownItems;
  List<GenericListModel>? shiftDropdownItems;

  ClinicModel? selectedClinic;
  GenericListModel? selectedShift;

  // Filters
  ReservationNewStatus? selectedStatus;
  List<ReservationNewStatus>? selectedStatusesList;
  String? selectedType;

  final List<String> reservationTypeFilters = [
    "كشف جديد",
    "كشف مستعجل",
    "إعادة",
    "متابعة",
  ];

  // Lifecycle
  @override
  Future<void> onInit() async {
    super.onInit();
    _initManagers();
    appointmentDate = DatesUtilis.todayAsString();
    await getClinicList();
  }

  void _initManagers() {
    queueManager = ReservationQueueManager();
    filterManager = ReservationFilterManager();
    actionManager = ReservationActionManager();
    queryManager = ReservationQueryManager();
    syncService = ReservationSyncService(controller: this);
  }

  @override
  void onClose() {
    syncService.dispose();
    super.onClose();
  }

  // Fetch reservations
  Future<void> getReservations({bool? isFilter}) async {
    if (appointmentDate == null) return;

    final query = filterManager.buildFilters(
      selectedClinic: selectedClinic,
      appointmentDate: appointmentDate,
      selectedTab: selectedTab,
      isFiltered: isFilter ?? true,
    );

    final all = await queryManager.getReservations(
      appointmentDate: appointmentDate,
      query: query,
    );

    completeDayReservations = all
        .where((r) => r.status == ReservationStatus.completed.value)
        .toList();

    listReservations = queueManager.buildFinalList(all);

    update();
  }

  // Get total reservations of today
  Future<int> getTotalTodayReservations() {
    return queryManager.getTotalByDate(appointmentDate: appointmentDate);
  }

  // Get last visit for patient
  Future<void> getLastReservationDateForPatient(LocalUser client) async {
    selectedPatientLastVisit = null;
    update();

    final reservation = await queryManager.getLastCompletedForPatient(
      client.key!,
    );

    selectedPatientLastVisit = reservation == null
        ? "لا يوجد كشف سابق"
        : DatesUtilis.humanizeTimestamp(reservation.createAt);

    update();
  }

  // Fetch clinic list
  Future<void> getClinicList() async {
    final clinicKey = LocalUser().getUserData().clinicKey ?? "";

    ClinicService().getClinicsData(
      data: {},
      filrebaseFilter: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: clinicKey.isNotEmpty,
        where: clinicKey.isNotEmpty ? "key = ?" : null,
        whereArgs: clinicKey.isNotEmpty ? [clinicKey] : [],
      ),
      voidCallBack: (data) {
        listClinic = data;
        Loader.dismiss();

        if (data.isNotEmpty) {
          clinicDropdownItems = ClinicAdapterUtil.convertClinicListToGeneric(
            data,
          );

          selectedClinic = data.first;

          getReservations();
          getSyncReservations();

          Future.delayed(const Duration(milliseconds: 300), () {
            _isInitialLoad = false;
          });
        }

        update();
      },
    );
  }

  // Start realtime sync
  void getSyncReservations() {
    syncService.listen(
      selectedClinic: selectedClinic,
      appointmentDate: appointmentDate,
      onAddLocal: (model) async {
        await actionManager.addReservation(model, localOnly: true);
      },
      onUpdatedLocal: (model) async {
        await actionManager.updateReservation(
          model,
          isSyncing: isSyncing,
          localOnly: true,
        );
      },
      onReloadLocal: () {
        if (_isInitialLoad || isSyncing) return;
        getReservations();
      },
    );
  }
}
