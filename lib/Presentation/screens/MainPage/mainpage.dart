import '../../../index/index_main.dart';
import 'package:flutter/cupertino.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  final int? innerIndex;

  const MainPage({Key? key, this.initialIndex = 0, this.innerIndex})
    : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  int backPressCount = 0;
  static const int backThreshold = 2;

  late final UserType? userType;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    userType = LocalUser().getUserData().userType;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: GetBuilder<MainPageViewModel>(
          init: MainPageViewModel(),
          builder: (_) {
            return Scaffold(
              backgroundColor: AppColors.white,

              // BODY
              body: _buildBody(currentIndex),

              // FAB (Patient only)
              // floatingActionButtonLocation: userType == UserType.patient
              //     ? FloatingActionButtonLocation.centerDocked
              //     : null,
              // floatingActionButton: userType == UserType.patient
              //     ? _buildFAB()
              //     : null,

              // BOTTOM NAV
              bottomNavigationBar: _buildBottomNavigationBar(),
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // 🔵 FAB
  // ------------------------------------------------------------------
  // Widget _buildFAB() {
  //   return GestureDetector(
  //     onTap: () => setState(() => currentIndex = 2),
  //     child: Container(
  //       width: 78.w,
  //       height: 78.h,
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         color: AppColors.primary,
  //         border: Border.all(color: AppColors.white, width: 4),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withValues(alpha: 0.15),
  //             blurRadius: 18,
  //             offset: const Offset(0, 6),
  //           ),
  //         ],
  //       ),
  //       child: Center(
  //         child: Svgicon(
  //           icon: IconsConstants.upload,
  //           width: 35.w,
  //           height: 35.h,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ------------------------------------------------------------------
  // 🔵 BOTTOM NAV (ORIGINAL + ASSISTANT BADGE)
  // ------------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    if (userType == null) return const SizedBox.shrink();

    // assistant only → realtime badge
    if (userType == UserType.assistant) {
      return GetBuilder<NotificationController>(
        init: NotificationController(),
        builder: (notifController) {
          return _buildNavContainer(
            _bottomItems(notifController: notifController),
          );
        },
      );
    }

    // others → original behavior
    return _buildNavContainer(_bottomItems());
  }

  Widget _buildNavContainer(List<BottomNavigationBarItem> items) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          tabLabelTextStyle: context.typography.smMedium,
          actionTextStyle: context.typography.mdMedium,
        ),
      ),
      child: CupertinoTabBar(
        backgroundColor: AppColors.primary.withOpacity(0.92),
        activeColor: CupertinoColors.white,
        inactiveColor: CupertinoColors.white.withValues(alpha: 0.6),
        iconSize: 28,
        height: 60.h,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: items,
      ),
    );
  }

  // ------------------------------------------------------------------
  // 🔵 BOTTOM ITEMS
  // ------------------------------------------------------------------
  List<BottomNavigationBarItem> _bottomItems({
    NotificationController? notifController,
  }) {
    switch (userType) {
      case UserType.patient:
        return [
          _item(IconsConstants.home, "الرئيسية"),
          _item(IconsConstants.new_reservae, "الحجوزات"),
          // const BottomNavigationBarItem(icon: SizedBox(), label: ""),
          _item(IconsConstants.orders, "الطلبات"),
          _item(IconsConstants.chat, "المحادثة"),
        ];

      case UserType.assistant:
        return [
          _item(IconsConstants.new_reservae, "الحجوزات"),
          notifController == null
              ? _item(IconsConstants.notification_mainpaage, "الإشعارات")
              : _itemWithBadge(
                  IconsConstants.notification_mainpaage,
                  "الإشعارات",
                  notifController.unreadCount,
                ),
          _item(IconsConstants.orders, "الطلبات"),
          _item(IconsConstants.account, "الحساب"),
        ];

      case UserType.doctor:
        return [
          _item(IconsConstants.new_reservae, "الحجوزات"),
          _item(IconsConstants.money, "الإيرادات"),
          _item(IconsConstants.feedback_icon, "التقييمات"),
          _item(IconsConstants.account, "الحساب"),
        ];

      case UserType.admin:
        return [
          _item(IconsConstants.category, "التخصصات"),
          _item(IconsConstants.sales, "المبيعات"),
          _item(IconsConstants.money, "الصيدلية"),
          _item(IconsConstants.account, "الحساب"),
        ];

      case UserType.sales:
        return [
          _item(IconsConstants.category, "التخصصات"),
          _item(IconsConstants.orders, "الزيارات"),
          _item(IconsConstants.account, "الحساب"),
        ];

      case UserType.pharmacy:
        return [
          _item(IconsConstants.money, "الصيدلية"),
          _item(IconsConstants.account, "الحساب"),
        ];

      default:
        return [_item(IconsConstants.home, "الرئيسية")];
    }
  }

  BottomNavigationBarItem _item(String icon, String label) {
    return BottomNavigationBarItem(
      icon: Svgicon(
        icon: icon,
        width: 24,
        height: 24,
        color: CupertinoColors.white.withOpacity(0.6),
      ),
      activeIcon: Svgicon(
        icon: icon,
        width: 26,
        height: 26,
        color: CupertinoColors.white,
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _itemWithBadge(String icon, String label, int count) {
    final normalIcon = Svgicon(
      icon: icon,
      width: 20.w,
      height: 20.h,
      color: AppColors.white.withValues(alpha: 0.5),
    );

    final activeIcon = Svgicon(
      icon: icon,
      width: 25.w,
      height: 25.h,
      color: AppColors.white,
    );

    return BottomNavigationBarItem(
      icon: NotificationBadge(icon: normalIcon, count: count),
      activeIcon: NotificationBadge(icon: activeIcon, count: count),
      label: label,
    );
  }

  // ------------------------------------------------------------------
  // 🔵 BODY ROUTING
  // ------------------------------------------------------------------
  Widget _buildBody(int index) {
    switch (userType) {
      case UserType.patient:
        return [
          const PatientHomeView(),
          const ReservationPatientView(),
          // const UploadPrescriptionScreen(),
          const OrdersListScreen(),
          const ChatListView(),
        ][index];

      case UserType.assistant:
        return [
          const ReservationView(),
          const NotificationsView(),
          const OrdersView(),
          const AccountView(),
        ][index];

      case UserType.doctor:
        return [
          const ReservationDoctorView(),
          const IncomeView(),
          const DoctorFeedbackView(),
          const AccountView(),
        ][index];

      case UserType.admin:
        return [
          const SpecializationView(),
          const SalesView(),
          const PharmacyView(),
          const AccountView(),
        ][index];

      case UserType.sales:
        return [
          const SpecializationView(),
          const VisitView(),
          const AccountView(),
        ][index];

      case UserType.pharmacy:
        return [const PharmacyOrdersListScreen(), const AccountView()][index];

      default:
        return const Center(child: Text("No page"));
    }
  }

  // ------------------------------------------------------------------
  // 🔵 BACK PRESS
  // ------------------------------------------------------------------
  Future<bool> _onBackPressed() async {
    if (backPressCount < backThreshold) {
      backPressCount++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text("اضغط رجوع مرة أخرى للخروج"),
        ),
      );
      return false;
    }
    return true;
  }
}
