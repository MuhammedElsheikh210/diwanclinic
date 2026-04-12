import '../../Presentation/screens/forceudpate/force_update_local.dart';
import '../../index/index_main.dart';

class RouteWelcomeMiddleWare extends GetMiddleware {
  RouteWelcomeMiddleWare({super.priority});

  @override
  RouteSettings? redirect(String? route) {
    final sessionUser = Get.find<UserSession>().user?.user;
    final forceUpdateModel = ForceUdpate().getForceUpdateData();

    print("Current route: $route");
    print("User type: ${sessionUser?.userType}");

    // ---------------------------------------------------------
    // 1️⃣ FORCE UPDATE FIRST
    // ---------------------------------------------------------
    if (forceUpdateModel?.forceUpdate == true) {
      if (route != forceUpdateView) {
        return const RouteSettings(name: forceUpdateView);
      }
      return null;
    }

    // ---------------------------------------------------------
    // 2️⃣ ONBOARD CHECK
    // ---------------------------------------------------------
    final hasSeenOnboard = OnboardLocalCheck.isOnboardSeen();

    if (!hasSeenOnboard) {
      if (route != onBoardView) {
        return const RouteSettings(name: onBoardView);
      }
      return null;
    }

    // ---------------------------------------------------------
    // 3️⃣ LOGIN CHECK
    // ---------------------------------------------------------
    if (sessionUser == null || sessionUser.uid == null) {
      if (route != loginView) {
        return const RouteSettings(name: loginView);
      }
      return null;
    }

    // ---------------------------------------------------------
    // 4️⃣ USER LOGGED IN → REDIRECT BASED ON TYPE
    // ---------------------------------------------------------
    final userType = sessionUser.userType;

    final targetRoute =
        (userType == UserType.patient ||
                userType == UserType.pharmacy ||
                userType == UserType.sales)
            ? mainpage
            : mainpage;

    if (route != targetRoute) {
      return RouteSettings(name: targetRoute);
    }

    return null;
  }
}
