import 'package:http/http.dart' as http;
import '../../../index/index_main.dart';

enum AdminUserFilter { all, doctors, pharmacy, patients }

class AdminUsersViewModel extends GetxController {
  // ============================================================
  // State
  // ============================================================

  AdminUserFilter selectedFilter = AdminUserFilter.all;
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  // ============================================================
  // Data
  // ============================================================

  List<LocalUser> _doctors = [];
  List<LocalUser> _assistants = [];
  List<LocalUser> _pharmacists = [];
  List<LocalUser> _patients = [];

  bool isLoadingDoctors = true;
  bool isLoadingPharmacy = true;
  bool isLoadingPatients = true;

  final Set<String> _expandedDoctorIds = {};

  // ============================================================
  // Lifecycle
  // ============================================================

  @override
  void onInit() {
    searchController.addListener(_onSearchChanged);
    _loadDoctors();
    _loadPharmacy();
    _loadPatients();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _searchQuery = searchController.text;
    update();
  }

  // ============================================================
  // Load
  // ============================================================

  void reloadData() {
    isLoadingDoctors = true;
    isLoadingPharmacy = true;
    isLoadingPatients = true;
    _doctors = [];
    _assistants = [];
    _pharmacists = [];
    _patients = [];
    update();
    _loadDoctors();
    _loadPharmacy();
    _loadPatients();
  }

  void _loadDoctors() {
    AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: 'userType', equalTo: 'doctor'),
      voidCallBack: (users) {
        _doctors = users;
        _loadAssistants();
      },
    );
  }

  void _loadAssistants() {
    AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: 'userType', equalTo: 'assistant'),
      voidCallBack: (users) {
        _assistants = users;
        isLoadingDoctors = false;
        update();
      },
    );
  }

  void _loadPharmacy() {
    AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: 'userType', equalTo: 'pharmacy'),
      voidCallBack: (users) {
        _pharmacists = users;
        isLoadingPharmacy = false;
        update();
      },
    );
  }

  void _loadPatients() {
    AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: 'userType', equalTo: 'patient'),
      voidCallBack: (users) {
        _patients = users;
        isLoadingPatients = false;
        update();
      },
    );
  }

  // ============================================================
  // Computed
  // ============================================================

  bool get isCurrentTabLoading {
    switch (selectedFilter) {
      case AdminUserFilter.all:
        return isLoadingDoctors || isLoadingPharmacy || isLoadingPatients;
      case AdminUserFilter.doctors:
        return isLoadingDoctors;
      case AdminUserFilter.pharmacy:
        return isLoadingPharmacy;
      case AdminUserFilter.patients:
        return isLoadingPatients;
    }
  }

  List<LocalUser> get filteredDoctors => _applySearch(_doctors);
  List<LocalUser> get filteredPharmacists => _applySearch(_pharmacists);
  List<LocalUser> get filteredPatients => _applySearch(_patients);

  List<LocalUser> get filteredAll {
    final combined = [
      ..._doctors,
      ..._assistants,
      ..._pharmacists,
      ..._patients,
    ];
    return _applySearch(combined);
  }

  int get totalCount =>
      _doctors.length + _assistants.length + _pharmacists.length + _patients.length;

  // Tab counts (shown in filter chips)
  int get doctorsCount => _doctors.length + _assistants.length;
  int get pharmacyCount => _pharmacists.length;
  int get patientsCount => _patients.length;

  List<LocalUser> assistantsOf(String doctorUid) {
    return _assistants
        .where((a) => a.doctorKey == doctorUid)
        .toList();
  }

  bool isDoctorExpanded(String doctorUid) =>
      _expandedDoctorIds.contains(doctorUid);

  void toggleDoctor(String doctorUid) {
    if (_expandedDoctorIds.contains(doctorUid)) {
      _expandedDoctorIds.remove(doctorUid);
    } else {
      _expandedDoctorIds.add(doctorUid);
    }
    update();
  }

  List<LocalUser> _applySearch(List<LocalUser> list) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((u) {
      final nameMatch = (u.name ?? '').toLowerCase().contains(q);
      final phoneMatch = (u.phone ?? '').contains(q);
      return nameMatch || phoneMatch;
    }).toList();
  }

  // ============================================================
  // Actions
  // ============================================================

  void onFilterChanged(AdminUserFilter filter) {
    selectedFilter = filter;
    update();
  }

  // Deletes from Realtime Database then calls Cloud Function to delete from Firebase Auth.
  void deleteUser(LocalUser user) {
    final uid = user.uid ?? '';
    if (uid.isEmpty) return;

    AuthenticationService().deleteClientsData(
      uid: uid,
      voidCallBack: (status) async {
        if (status == ResponseStatus.success) {
          _removeLocally(uid);
          update();
          // Delete from Firebase Auth via Cloud Function
          await _deleteFromAuth(uid);
          Loader.showSuccess('تم حذف المستخدم بنجاح');
        } else {
          Loader.showError('فشل حذف المستخدم');
        }
      },
    );
  }

  Future<void> _deleteFromAuth(String uid) async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) return;

      final response = await http.post(
        Uri.parse(
          'https://us-central1-link-b47c8.cloudfunctions.net/deleteAuthUser',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'uid': uid}),
      );

      if (response.statusCode != 200) {
        Get.log('Auth delete failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Non-blocking — RTDB data already removed
      Get.log('Auth delete error: $e');
    }
  }

  void _removeLocally(String uid) {
    _doctors.removeWhere((u) => u.uid == uid);
    _assistants.removeWhere((u) => u.uid == uid);
    _pharmacists.removeWhere((u) => u.uid == uid);
    _patients.removeWhere((u) => u.uid == uid);
  }
}
