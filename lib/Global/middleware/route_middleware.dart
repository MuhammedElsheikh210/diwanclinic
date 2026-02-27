import '../../Presentation/screens/forceudpate/force_update_local.dart';
import '../../index/index_main.dart';

class RouteWelcomeMiddleWare extends GetMiddleware {
  RouteWelcomeMiddleWare({super.priority});

  @override
  RouteSettings? redirect(String? route) {
    final user = LocalUser().getUserData();
    final forceUpdateModel = ForceUdpate().getForceUpdateData();

    print("Current route: $route");
    print("User type: ${user.userType}");

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
    if (user.key == null || user.uid == null) {
      if (route != loginView) {
        return const RouteSettings(name: loginView);
      }
      return null;
    }

    // ---------------------------------------------------------
    // 4️⃣ USER LOGGED IN → REDIRECT BASED ON TYPE
    // ---------------------------------------------------------
    final targetRoute =
        (user.userType == UserType.patient ||
            user.userType == UserType.pharmacy ||
            user.userType == UserType.sales)
        ? mainpage
        : syncView;

    if (route != targetRoute) {
      return RouteSettings(name: targetRoute);
    }

    return null;
  }
}
