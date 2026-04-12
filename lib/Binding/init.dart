
import 'package:firebase_database/firebase_database.dart';
import '../index/index_main.dart';

class Binding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientSourceRepo>(() => ClientSourceRepo(), fenix: true);
    Get.lazyPut<FirebaseClient>(() => FirebaseClient(), fenix: true);
    Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);

    // ───────────── Authentication (Fixed Clean Architecture) ─────────────

    // 🔹 Local DS
    Get.lazyPut<AuthenticationDataSourceRepo>(
      () => AuthenticationDataSourceRepoImpl(),
      fenix: true,
    );

    // 🔹 Remote DS
    Get.lazyPut<AuthenticationRemoteDataSource>(
      () => AuthenticationRemoteDataSourceImpl(
        FirebaseDatabase.instance,
        Get.find<ClientSourceRepo>(),
      ),
      fenix: true,
    );

    // 🔹 Repository
    Get.lazyPut<AuthenticationRepository>(
      () => AuthenticationRepositoryImpl(
        Get.find<AuthenticationDataSourceRepo>(),
        Get.find<AuthenticationRemoteDataSource>(),
        Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    // ───────────── Data Sources ─────────────
    Get.lazyPut<DoctorListRemoteDataSource>(
      () => DoctorListRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<MedicalCenterDataSourceRepo>(
      () => MedicalCenterDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<LegacyQueueDataSourceRepo>(
      () => LegacyQueueDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<MedicineDataSourceRepo>(
      () => MedicineDataSourceRepoImpl(),
      fenix: true,
    );

    // Get.lazyPut<SyncDataSourceRepo>(
    //   () => SyncRemoteDataSourceImpl(Get.find()),
    //   fenix: true,
    // );

    Get.lazyPut<TransactionsDataSourceRepo>(
      () => TransactionsDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<CategoryDataSourceRepo>(
      () => CategoryDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<Firebase_DataSourceRepo>(
      () => FirebaseRemote_DataSourceImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<DoctorSuggestionDataSourceRepo>(
      () => DoctorSuggestionDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<ArchivePatientDataSourceRepo>(
      () => ArchivePatientDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<DoctorDataSourceRepo>(
      () => DoctorDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<PatientDataSourceRepo>(
      () => PatientDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<AssistantDataSourceRepo>(
      () => AssistantDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<ClinicDataSourceRepo>(
      () => ClinicDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<FilesDataSourceRepo>(
      () => FilesDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<TransferDataSourceRepo>(
      () => TransferDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<ShiftDataSourceRepo>(
      () => ShiftDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<DoctorReviewDataSourceRepo>(
      () => DoctorReviewDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<IncomeDataSourceRepo>(
      () => IncomeDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<MedicalCenterRepository>(
      () => MedicalCenterRepositoryImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<OrderDataSourceRepo>(
      () => OrderDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(
        FirebaseDatabase.instance,
        Get.find<ClientSourceRepo>(),
      ),
      fenix: true,
    );

    Get.lazyPut<VisitDataSourceRepo>(
      () => VisitDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<ArchiveFormDataSourceRepo>(
      () => ArchiveFormDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    // ───────────── Reservation (Fixed Clean Architecture) ─────────────

    Get.lazyPut<ReservationDataSourceRepo>(
      () => ReservationDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut<ReservationRemoteDataSource>(
      () => ReservationRemoteDataSourceImpl(FirebaseDatabase.instance),
      fenix: true,
    );

    Get.lazyPut<ReservationRepository>(
      () => ReservationRepositoryImpl(
        Get.find<ReservationDataSourceRepo>(),
        Get.find<ReservationRemoteDataSource>(),
        Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    // ───────────── Repositories ─────────────
    Get.lazyPut<MedicineRepository>(
      () => MedicineRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<DoctorListRepository>(
      () => DoctorListRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<LegacyQueueRepository>(
      () => LegacyQueueRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<SyncRepository>(() => SyncRepoImpl(Get.find()), fenix: true);
    Get.lazyPut<TransactionsRepository>(
      () => TransactionsRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ArchivePatientRepository>(
      () => ArchivePatientRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<FirebaseRepository>(
      () => FirebaseRepoImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<DoctorRepository>(
      () => DoctorRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<PatientRepository>(
      () => PatientRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<AssistantRepository>(
      () => AssistantRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ClinicRepository>(
      () => ClinicRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<FilesRepository>(
      () => FilesRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<TransferRepository>(
      () => TransferRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ShiftRepository>(
      () => ShiftRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<DoctorReviewRepository>(
      () => DoctorReviewRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<IncomeRepository>(
      () => IncomeRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<OrderRepository>(
      () => OrderRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<NotificationRepository>(
      () =>
          NotificationRepositoryImpl(Get.find<NotificationRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<VisitRepository>(
      () => VisitRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ArchiveFormRepository>(
      () => ArchiveFormRepositoryImpl(Get.find()),
      fenix: true,
    );

    // ───────────── Use Cases ─────────────
    Get.lazyPut<ClinicUseCases>(() => ClinicUseCases(Get.find()));
    Get.lazyPut<NotificationUseCases>(() => NotificationUseCases(Get.find()));
    Get.lazyPut<VisitUseCases>(() => VisitUseCases(Get.find()));
    Get.lazyPut<ArchivePatientUseCases>(
      () => ArchivePatientUseCases(Get.find()),
    );
    Get.lazyPut<ArchiveFormUseCases>(() => ArchiveFormUseCases(Get.find()));

    // ───────────── ViewModels ─────────────
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
    Get.lazyPut<MainPageViewModel>(() => MainPageViewModel());
    Get.lazyPut<ReservationViewModel>(() => ReservationViewModel());
  }
}
