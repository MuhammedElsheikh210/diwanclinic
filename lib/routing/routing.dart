
import '../index/index_main.dart';

const String mainpage = "/MainPage";
const String reservationSuccessView = "/ReservationSuccessView";
const String doctorFeedbackView = "/DoctorFeedbackView";

const String loginView = "/LoginView";
const String test = "/Test";
const String expenceCategoryView = "/ExpenceCategoryView";
const String createExpenseCategoryView = "/CreateExpenseCategoryView";
const String expenseView = "/ExpenseView";
const String createExpenseView = "/CreateExpenseView";
const String addCustomerView = "/AddCustomerView";
const String categoryView = "/CategoryView";
const String expenseCategoryView = "/ExpenseCategoryView";
const String syncView = "/SyncView";
const String clinicView = "/ClinicView";
const String createClinicView = "/CreateClinicView";
const String assistantView = "/AssistantView";
const String createAssistantView = "/CreateAssistantView";
const String createPatientView = "/CreatePatientView";
const String patientView = "/PatientView";
const String reservationView = "/ReservationView";
const String reservationDoctorView = "/ReservationDoctorView";
const String reservationHistoryView = "/ReservationHistoryView";
const String accountView = "/AccountView";
const String helpCenterView = "/HelpCenterView";
const String ordersView = "/OrdersView";
const String testSendNotificationView = "/TestSendNotificationView";
const String whatsAppGroupView = "/WhatsAppGroupView";
const String notificationsView = "/NotificationsView";
const String forceUpdateView = "/ForceUpdateView";
const String patientHomeView = "/PatientHomeView";
const String ordersListScreen = "/OrdersListScreen";
const String legacyQueueView = "/LegacyQueueView";
const String openclosereservationView = "/OpenclosereservationView";

class Routes {
  static List<GetPage<dynamic>> handle_routes() {
    return [
      GetPage(
        name: mainpage,
        page: () => const MainPage(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
        //  middlewares: [RouteWelcomeMiddleWare(priority: 1)],
      ),
      GetPage(
        name: reservationView,
        page: () => const ReservationView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: forceUpdateView,
        page: () => const ForceUpdateView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),



      GetPage(
        name: openclosereservationView,
        page: () => const OpenclosereservationView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),

      GetPage(
        name: ordersListScreen,
        page: () => const OrdersListScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: legacyQueueView,
        page: () => const LegacyQueueView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: doctorFeedbackView,
        page: () => const DoctorFeedbackView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: reservationSuccessView,
        page: () => const ReservationSuccessView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: whatsAppGroupView,
        page: () => const WhatsAppGroupView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),

      GetPage(
        name: patientHomeView,
        page: () => const PatientHomeView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: ordersView,
        page: () => const OrdersView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: notificationsView,
        page: () => const NotificationsView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: accountView,
        page: () => const AccountView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: helpCenterView,
        page: () => const HelpCenterView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),

      GetPage(
        name: expenseCategoryView,
        page: () => const ExpenseCategoryView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: createPatientView,
        page: () => const CreatePatientView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: patientView,
        page: () => const PatientView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: reservationDoctorView,
        page: () => const ReservationDoctorView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: assistantView,
        page: () => const AssistantView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: createAssistantView,
        page: () => const CreateAssistantView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: categoryView,
        page: () => const CategoryView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),

      GetPage(
        name: clinicView,
        page: () => const ClinicView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: createClinicView,
        page: () => const CreateClinicView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: syncView,
        page: () => const SyncView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
        // middlewares: [RouteWelcomeMiddleWare(priority: 1)],
      ),

      GetPage(
        name: expenseView,
        page: () => const ExpenseView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),

      GetPage(
        name: createExpenseView,
        page: () => const CreateExpenseView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),

      GetPage(
        name: expenceCategoryView,
        page: () => const CategoryView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: createExpenseCategoryView,
        page: () => const CreateCategoryView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: loginView,
        page: () => const LoginView(),
        transitionDuration: const Duration(milliseconds: 500),
        binding: Binding(),
        transition: Transition.cupertino,
        middlewares: [RouteWelcomeMiddleWare(priority: 1)],
      ),
      GetPage(
        name: test,
        page: () => const Test(),
        binding: Binding(),
        transition: Transition.cupertino,
      ),
    ];
  }
}
