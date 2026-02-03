import 'package:diwanclinic/Data/RepositoryImpl/legacy_queue_repository_impl.dart';
import 'package:diwanclinic/Data/data_source_impl/legacy_queue_data_source_repo_impl.dart';
import 'package:diwanclinic/Presentation/screens/order_medicine_view/order_medicine_view_model.dart';

import '../index/index_main.dart';

class Binding implements Bindings {
  @override
  void dependencies() {
    // ───────────── Core ─────────────
    Get.lazyPut<ClientSourceRepo>(() => ClientSourceRepo(), fenix: true);
    Get.lazyPut<FirebaseClient>(() => FirebaseClient(), fenix: true);

    // ───────────── Data Sources ─────────────
    Get.lazyPut<AuthenticationDataSourceRepo>(
      () => AuthenticationRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );

    // ───────────── Legacy Queue Data Source ─────────────
    Get.lazyPut<LegacyQueueDataSourceRepo>(
      () => LegacyQueueDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    // ───────────── Medicine Data Source ─────────────
    Get.lazyPut<MedicineDataSourceRepo>(
      () => MedicineDataSourceRepoImpl(),
      fenix: true,
    );

    Get.lazyPut<SyncDataSourceRepo>(
      () => SyncRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );
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
    Get.lazyPut<ReservationDataSourceRepo>(
      () => ReservationDataSourceRepoImpl(Get.find()),
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
    Get.lazyPut<OrderDataSourceRepo>(
      () => OrderDataSourceRepoImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<NotificationDataSourceRepo>(
      () => NotificationDataSourceRepoImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<VisitDataSourceRepo>(
      () => VisitDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    // ───────────── Medicine Repository ─────────────
    Get.lazyPut<MedicineRepository>(
      () => MedicineRepositoryImpl(Get.find()),
      fenix: true,
    );

    // 🆕 💬 Doctor Suggestion Data Source
    Get.lazyPut<DoctorSuggestionDataSourceRepo>(
      () => DoctorSuggestionDataSourceRepoImpl(Get.find()),
      fenix: true,
    );

    // ───────────── Domain Repositories ─────────────
    Get.lazyPut<AuthenticationRepository>(
      () => AuthenticationRepoImpl(Get.find()),
      fenix: true,
    );

    // ───────────── Legacy Queue Repository ─────────────
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
    Get.lazyPut<ReservationRepository>(
      () => ReservationRepositoryImpl(Get.find()),
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
      () => NotificationRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<VisitRepository>(
      () => VisitRepositoryImpl(Get.find()),
      fenix: true,
    );

    // 🆕 💬 Doctor Suggestion Repository
    Get.lazyPut<DoctorSuggestionRepository>(
      () => DoctorSuggestionRepositoryImpl(Get.find()),
      fenix: true,
    );

    // ───────────── Use Cases ─────────────
    Get.lazyPut<ClinicUseCases>(() => ClinicUseCases(Get.find()));
    Get.lazyPut<NotificationUseCases>(() => NotificationUseCases(Get.find()));
    Get.lazyPut<VisitUseCases>(() => VisitUseCases(Get.find()));

    // 🆕 💬 Doctor Suggestion Use Cases
    Get.lazyPut<DoctorSuggestionUseCases>(
      () => DoctorSuggestionUseCases(Get.find()),
    );

    // ───────────── View Models / Controllers ─────────────
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
    Get.lazyPut<CalenderViewModel>(() => CalenderViewModel());
    Get.lazyPut<OtpViewModel>(() => OtpViewModel());
    Get.lazyPut<ParentSyncService>(() => ParentSyncService());
    Get.lazyPut<SyncViewModel>(() => SyncViewModel());
    Get.lazyPut<CategoryExpenseViewModel>(() => CategoryExpenseViewModel());
    Get.lazyPut<ClinicViewModel>(() => ClinicViewModel());
    Get.lazyPut<CreateClinicViewModel>(() => CreateClinicViewModel());
    Get.lazyPut<CreateAssistantViewModel>(() => CreateAssistantViewModel());
    Get.lazyPut<AssistantViewModel>(() => AssistantViewModel());
    Get.lazyPut<PatientViewModel>(() => PatientViewModel());
    Get.lazyPut<CreatePatientViewModel>(() => CreatePatientViewModel());
    Get.lazyPut<CreateReservationViewModel>(() => CreateReservationViewModel());
    Get.lazyPut<ReservationViewModel>(() => ReservationViewModel());
    Get.lazyPut<ShiftViewModel>(() => ShiftViewModel());
    Get.lazyPut<CreateShiftViewModel>(() => CreateShiftViewModel());
    Get.lazyPut<ReservationDoctorViewModel>(() => ReservationDoctorViewModel());
    Get.lazyPut<PatientProfileHistoryViewModel>(
      () => PatientProfileHistoryViewModel(),
    );
    Get.lazyPut<PatientProfileAllHistoryViewModel>(
      () => PatientProfileAllHistoryViewModel(),
    );
    Get.lazyPut<AccountViewModel>(() => AccountViewModel());
    Get.lazyPut<ChatViewModel>(() => ChatViewModel());
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel());
    Get.lazyPut<PatientForAssistantProfileHistoryViewModel>(
      () => PatientForAssistantProfileHistoryViewModel(),
    );
    Get.lazyPut<DoctorFeedbackViewModel>(() => DoctorFeedbackViewModel());
    Get.lazyPut<MainPageViewModel>(() => MainPageViewModel());
    Get.lazyPut<SpecializationViewModel>(() => SpecializationViewModel());
    Get.lazyPut<PharmacyViewModel>(() => PharmacyViewModel());
    Get.lazyPut<CreatePharmacyViewModel>(() => CreatePharmacyViewModel());
    Get.lazyPut<ReservationPatientViewModel>(
      () => ReservationPatientViewModel(),
    );
    // ───────────── Pricing Search ─────────────
    Get.lazyPut<PricingSearchController>(() => PricingSearchController());
    Get.lazyPut<HomePatientController>(() => HomePatientController());
  }
}
